{
  description = "Shadowfax system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    lume = {
      url = "github:trycua/lume";
      flake = false;
    };
    mac-app-util = {
      url = "github:hraban/mac-app-util";
    };
  };

  outputs =
    inputs@{
      self,
      darwin,
      nix-homebrew,
      homebrew-bundle,
      homebrew-core,
      homebrew-cask,
      home-manager,
      lume,
      nixpkgs,
      mac-app-util,
      ...
    }:
    let
      user = "jklapacz";
      configuration =
        { pkgs, ... }:
        {
          nixpkgs.config.allowUnfree = true;

          system.configurationRevision = self.rev or self.dirtyRev or null;
          system.stateVersion = 4;

          fonts.packages = with pkgs; [
            nerd-fonts.fira-code
            nerd-fonts.hack
            nerd-fonts.jetbrains-mono
            nerd-fonts._0xproto
          ];

          # Replace with x86_64-darwin if on Intel Mac
          nixpkgs.hostPlatform = "aarch64-darwin";

          users.users.${user} = {
            name = user;
            home = "/Users/${user}";
          };

          programs.zsh.enable = true;
          environment.systemPackages = with pkgs; [
            nixfmt-rfc-style
            docker
            neofetch
            neovim
            dockutil
          ];

          programs.direnv = {
            enable = true;
            nix-direnv.enable = true;
          };

          homebrew = {
            enable = true;
            taps = [
              "homebrew/homebrew-core"
              "homebrew/homebrew-cask"
              "homebrew/homebrew-bundle"
              "trycua/lume"
            ];
            brews = [
              "lume"
              "uv"
            ];
            casks = [
              "caffeine"
              "cursor"
              "claude"
              "docker"
              "firefox"
              "google-chrome"
              "moom"
              "slack"
              "visual-studio-code"
            ];
            onActivation.cleanup = "zap";
          };

          security.sudo.extraConfig = ''
            ${user} ALL = (ALL) NOPASSWD: ALL
          '';

        };

      homeconfig =
        { pkgs, lib, ... }:
        {
          imports = [
            ./modules/cursor.nix
          ];

          programs.cursor = {
            enable = true;
            package =
              if pkgs.stdenv.hostPlatform.system == "aarch64-darwin" then
                "/opt/homebrew/bin/cursor"
              else
                "/usr/local/bin/cursor";
            extensions = [
              "asvetliakov.vscode-neovim"
              "jnoortheen.nix-ide"
              "ms-python.debugpy"
              "ms-python.python"
              "ms-python.vscode-pylance"
            ];
            settings = {
              "window.commandCenter" = 1;
              "editor.formatOnSave" = true;
              "extensions.experimental.affinity" = {
                "asvetliakov.vscode-neovim" = 1;
              };
            };
          };

          home.stateVersion = "23.05";
          # Let home-manager install and manage itself.
          programs.home-manager.enable = true;

          home.packages = with pkgs; [
            pkgs.hello
            openssh
            wezterm
            nix-direnv
          ];

          home.sessionVariables = {
            EDITOR = "nvim";
          };

          programs.zsh = {
            enable = true;
            shellAliases = {
              switch = "darwin-rebuild switch --flake ~/.config/nix";
            };
          };

          programs.atuin = {
            enable = true;
            enableBashIntegration = true;
            enableZshIntegration = true;
            flags = [ "--disable-up-arrow" ];
          };

          programs.eza = {
            enable = true;
            enableZshIntegration = true;
          };

          programs.git = {
            enable = true;
            userName = "Jakub Klapacz";
            userEmail = "jakub@gordiansoftware.com";
            ignores = [ ".DS_STORE" ];
            extraConfig = {
              init.defaultBranch = "main";
              push.autoSetupRemote = true;
            };
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

              config.font = wezterm.font("0xProto Nerd Font")
              config.font_size = 14.0
              return config
            '';
          };

          home.file.".ssh/config".text = ''
            # Default GitHub account (work)
            Host github.com
              HostName github.com
              User git
              IdentityFile ~/.ssh/id_ed25519_work
              
            # Personal GitHub account
            Host github-personal
              HostName github.com
              User git
              IdentityFile ~/.ssh/id_ed25519_personal
          '';

          # Generate SSH keys if they don't exist
          home.activation.generateSSHKeys = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            if [ ! -f "$HOME/.ssh/id_ed25519_personal" ]; then
              $DRY_RUN_CMD ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -C "kubaklapacz@gmail.com" -f "$HOME/.ssh/id_ed25519_personal" -N ""
            fi
            if [ ! -f "$HOME/.ssh/id_ed25519_work" ]; then
              $DRY_RUN_CMD ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -C "jakub@gordiansoftware.com" -f "$HOME/.ssh/id_ed25519_work" -N ""
            fi
          '';

          # Create a Git configuration template
          home.file.".gitconfig".text = ''
            [user]
              name = Jakub Klapacz
              email = jakub@gordiansoftware.com

            [includeIf "gitdir:~/.config/nix/"]
              path = ~/.gitconfig-personal
          '';

          home.file.".gitconfig-personal".text = ''
            [user]
              name = Jakub Klapacz
              email = kubaklapacz@gmail.com
          '';

        };
    in
    {
      darwinConfigurations."Shadowfax" = darwin.lib.darwinSystem {
        modules = [
          configuration
          mac-app-util.darwinModules.default
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix = {
              enable = false;
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.verbose = true;
            home-manager.users.jklapacz = homeconfig;
            home-manager.sharedModules = [
              mac-app-util.homeManagerModules.default
            ];
            nix-homebrew = {
              inherit user;
              enable = true;
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "homebrew/homebrew-bundle" = homebrew-bundle;
                "trycua/lume" = lume; # Add this line
              };
              mutableTaps = true;
              autoMigrate = false;
            };
          }
          ./hosts/darwin
        ];
      };
    };
}
