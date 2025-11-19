{ config, pkgs, ... }:
{
  programs.zsh.enable = true;
  users.users.maddy.shell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];
}
