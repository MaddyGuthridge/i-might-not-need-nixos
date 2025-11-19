{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gcc
    clang
    clang-tools
    libxcrypt
    gnumake
    (builtins.getFlake "github:MaddyGuthridge/dcc?ref=master").packages.x86_64-linux.default
  ];
}
