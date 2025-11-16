#!/usr/bin/env bash
# rebuild.sh
# Rebuild NixOS from this configuration
sudo cp ./configuration.nix /etc/nixos/configuration.nix
sudo nixos-rebuild switch
