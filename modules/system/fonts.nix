{ config, lib, pkgs, ... }:

{
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.jetbrains-mono
    nerd-fonts._0xproto
  ];
}