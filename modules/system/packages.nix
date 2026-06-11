{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nixfmt
    fastfetch
    neovim
    dockutil
    docker
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
