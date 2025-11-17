# I am specifically using Gradle 8.8, since it is required for COMP2511 at UNSW
{
  description = "Tools for ripping and viewing physical media, including Blu-rays";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
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
      packages.x86_64-linux.vlc = vlcBd;
      packages.x86_64-linux.handbrake = handbrakeBd;
      packages.x86_64-linux.makemkv = pkgs.makemkv;
    };
}
