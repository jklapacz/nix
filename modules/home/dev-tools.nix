{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    awscli2
    devenv
    gh
    nix-direnv
    openssh
    ssm-session-manager-plugin
    terraform
    uv
    wezterm
    rsync
    biome
    postgresql_17_jit
    customClaude.claude
    nodejs_24
    python312
    python312Packages.pip
    python312Packages.tiktoken
  ];
}