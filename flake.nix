{
  description = "The root configuration for my Kronk system";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
    }:
    let
      /**
        Define a computer and its configuration
      */
      puter =
        {
          pkgs,
          nixpkgs-unstable,
          hostname,
          arch,
        }:
        let
          unstablePkgs = import nixpkgs-unstable {
            system = arch;
            # https://discourse.nixos.org/t/allow-unfree-in-flakes/29904/2
            config.allowUnfree = true;
          };
        in
        pkgs.lib.nixosSystem {
          system = arch;
          modules = [
            { networking.hostName = hostname; }
            (./. + "/puters/${hostname}/configuration.nix")
            home-manager.nixosModules.home-manager
          ];
          specialArgs = { inherit unstablePkgs; };
        };
    in
    {
      nixosConfigurations = {
        kronk = puter {
          pkgs = nixpkgs;
          nixpkgs-unstable = nixpkgs-unstable;
          hostname = "kronk";
          arch = "x86_64-linux";
        };
      };
    };
}
