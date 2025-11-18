{ config, pkgs, ... }:
{
  imports = [
    ./programming
    ./teaching
    ./communication.nix
    ./documents.nix
    ./media.nix
  ];
}
