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
          unstablePkgs,
          hostname,
          arch,
        }:
        pkgs.lib.nixosSystem {
          system = arch;
          modules = [
            {networking.hostname = hostname;}
            (./. + "/puters/${hostname}/configuration.nix")
            home-manager.nixosModules.home-manager
          ];
        };
    in
    {
      nixosConfigurations = {
        kronk = puter {
          pkgs = nixpkgs;
          unstablePkgs = nixpkgs-unstable;
          hostname = "kronk";
          arch = "x86_64-linux";
        };
      };
    };
}
