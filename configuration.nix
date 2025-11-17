# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  # Home manager
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";

  # Add the unstable channel declaratively
  unstableTarball = fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";

  # https://discourse.nixos.org/t/new-to-nixos-and-cant-play-blu-rays/62560/5
  # https://github.com/NixOS/nixpkgs/issues/75646#issuecomment-1832829819
  libbluray = pkgs.libbluray.override {
    withAACS = true;
    withBDplus = true;
    withJava = true;
  };
  vlcBd = pkgs.vlc.override { inherit libbluray; };
  handbrakeBd = pkgs.handbrake.override { inherit libbluray; };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Home manager
    (import "${home-manager}/nixos")
  ];

  nixpkgs.config = {
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Bootloader.
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
    extraEntries = {
      "Fedora.conf" = ''
        title Fedora
        efi /EFI/fedora/grubx64.efi
        options root=9A09-B0A7 rootfstype=fat32 add_efi_memmap rw
        sort-key fedora
      '';
    };
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [
    # Required for makemkv to work correctly
    # https://discourse.nixos.org/t/makemkv-cant-find-my-usb-blu-ray-drive/23714/4
    "sg"
  ];

  # Additional file systems
  fileSystems."/media/yzma" = {
    device = "/dev/disk/by-uuid/26d0f537-4884-4344-bd85-04a20a610b41";
    fsType = "btrfs";
  };

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "kronk"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Australia/Sydney";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_AU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.maddy =
    let
      # Use Gradle 8.8
      archivePkgs = import (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/d9f258945d3532e399d7f73fcd9b6fa5b4393e01.tar.gz";
      }) { };
      gradle_8_8 = archivePkgs.gradle_8;
    in
    {
      isNormalUser = true;
      description = "Maddy Guthridge";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];

      packages = with pkgs; [
        # Gnome
        gnome-tweaks
        gnomeExtensions.launch-new-instance
        gnomeExtensions.caffeine
        gnomeExtensions.appindicator
        gnomeExtensions.blur-my-shell
        gnomeExtensions.pip-on-top
        gnomeExtensions.gsconnect
        gnomeExtensions.hide-minimized
        gnomeExtensions.lock-keys
        gnomeExtensions.just-perfection
        gnomeExtensions.rounded-window-corners-reborn
        gnomeExtensions.panel-workspace-scroll
        gnomeExtensions.middle-click-to-close-in-overview
        gnomeExtensions.pano
        wl-clipboard
        # Note-taking
        unstable.obsidian
        libreoffice-qt6-fresh
        # Communication
        unstable.thunderbird
        unstable.teams-for-linux
        unstable.discord
        slack
        zoom-us
        signal-desktop
        # Programming
        ghostty
        unstable.vscode
        unstable.zed-editor
        unstable.nushell
        insomnia
        unstable.typst
        android-tools
        # mise  # I muse resist the temptation
        # JS
        nodejs_20
        unstable.bun
        # Python
        unstable.uv
        poetry
        # Java
        jdk17
        gradle_8_8
        jdt-language-server
        # Rust
        rustup
        bacon
        # Nix
        nil
        nixfmt-rfc-style
        # Media
        unstable.makemkv
        vlcBd
        jellyfin-media-player
        mkvtoolnix
        handbrakeBd
      ];
    };

  # Allow running arbitrary executables
  # https://nix.dev/guides/faq#how-to-run-non-nix-executables
  programs.nix-ld.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    zsh
    usbutils
    git
    hack-font
    unstable.cloudflared
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
