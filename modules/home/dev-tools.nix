{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    ansible
    awscli2
    bootstrap
    biome
    claude-code
    codex
    devenv
    gh
    ghidra-with-mcp
    git-lfs
    herdr
    nil
    nixd
    nix-direnv
    nodejs_24
    opencode
    openssh
    pi-coding-agent
    postgresql_17_jit
    python312
    python312Packages.pip
    python312Packages.tiktoken
    rea-agents
    ripgrep
    rsync
    ssm-session-manager-plugin
    tart
    terraform
    uv
    wezterm
  ];

  # Installs the JDK and sets JAVA_HOME
  programs.java = {
    enable = true;
    package = pkgs.openjdk21;
  };
}
