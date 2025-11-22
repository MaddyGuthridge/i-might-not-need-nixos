{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    unstable.thunderbird
    unstable.teams-for-linux
    unstable.discord
    slack
    zoom-us
    signal-desktop
  ];
}
