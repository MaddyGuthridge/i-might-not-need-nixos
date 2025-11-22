{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (builtins.getFlake "path:///home/maddy/Source/nix-experiment/config/activities/teaching/slides-xp")
    .packages.x86_64-linux.default
  ];
}
