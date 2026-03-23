{ config, lib, pkgs, ... }:

{
  home.sessionVariables = {
    EDITOR = "nvim";
    PYTHONDONTWRITEBYTECODE = 1;
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      switch = "sudo darwin-rebuild switch --flake ~/.config/nix";
      gap = "git add -p";
      gcm = "git commit -m";
      gst = "git status";
      gsw = "git switch";
      aws-login = "aws sso login --sso-session gordian-aws && aws sso login --profile gordian-infra-orchestration-tfstate-access";
    };
    initExtra = ''
      export PYTHONDONTWRITEBYTECODE=1
      if [ -f "$HOME/.secrets" ]; then
        source "$HOME/.secrets"
      fi

      # Add /opt/gordian/bin to PATH if it exists
      if [ -d "/opt/gordian/bin" ]; then
        export PATH="/opt/gordian/bin:$PATH"
      fi

      export PATH="$HOME/.local/bin:$PATH"

      export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
      export PATH="$ANDROID_SDK_ROOT/platform-tools:$PATH"
    '';
  };

  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      # Disable automatic enter after selection
      enter_accept = false;
      search_mode = "fuzzy";
    };
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
    };
  };

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require "wezterm"
      local config = {}
      if wezterm.config_builder then
        config = wezterm.config_builder()
      end
      config.color_scheme = "Nord (Gogh)"
      config.color_scheme = "Catppuccin Mocha"

      config.font = wezterm.font("FiraCode Nerd Font")
      config.font_size = 14.0
      return config
    '';
  };
}