{
  description = "Shadowfax system configuration";

  inputs = {
    fh.url = "https://flakehub.com/f/DeterminateSystems/fh/*";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      fh,
      mac-app-util,
      ...
    }:
    let
      configuration =
        { pkgs, ... }:
        {
          nixpkgs.config.allowUnfree = true;
          services.nix-daemon.enable = true;
          nix.settings = {
            experimental-features = [
              "nix-command"
              "flakes"
            ];
            max-jobs = "auto";
            bash-prompt-prefix = "(nix:$name)\040";
            netrc-file = "/nix/var/determinate/netrc";
            post-build-hook = "/nix/var/determinate/post-build-hook.sh";
            always-allow-substitutes = true;
            extra-substituters = [ "https://cache.flakehub.com" ];
            extra-trusted-public-keys = [
              "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
              "cache.flakehub.com-4:Asi8qIv291s0aYLyH6IOnr5Kf6+OF14WVjkE6t3xMio="
              "cache.flakehub.com-5:zB96CRlL7tiPtzA9/WKyPkp3A2vqxqgdgyTVNGShPDU="
              "cache.flakehub.com-6:W4EGFwAGgBj3he7c5fNh9NkOXw0PUVaxygCVKeuvaqU="
              "cache.flakehub.com-7:mvxJ2DZVHn/kRxlIaxYNMuDG1OvMckZu32um1TadOR8="
              "cache.flakehub.com-8:moO+OVS0mnTjBTcOUh2kYLQEd59ExzyoW1QgQ8XAARQ="
              "cache.flakehub.com-9:wChaSeTI6TeCuV/Sg2513ZIM9i0qJaYsF+lZCXg0J6o="
              "cache.flakehub.com-10:2GqeNlIp6AKp4EF2MVbE1kBOp9iBSyo0UPR9KoR0o1Y="
            ];
            upgrade-nix-store-path-url = "https://install.determinate.systems/nix-upgrade/stable/universal";
            extra-nix-path = "nixpkgs=flake:https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/*.tar.gz";
            ssl-cert-file = "/private/etc/nix/macos-keychain.crt";
          };

          system.configurationRevision = self.rev or self.dirtyRev or null;
          system.stateVersion = 4;

          # Replace with x86_64-darwin if on Intel Mac
          nixpkgs.hostPlatform = "aarch64-darwin";

          users.users.jklapacz = {
            name = "jklapacz";
            home = "/Users/jklapacz";
          };

          programs.zsh.enable = true;
          environment.systemPackages = [
            pkgs.nixfmt-rfc-style
            pkgs.docker
            pkgs.neofetch
            pkgs.neovim
            fh.packages.aarch64-darwin.default
          ];

          launchd.user.agents.docker-desktop = {
            serviceConfig = {
              ProgramArguments = [
                "/Applications/Docker.app/Contents/MacOS/Docker Desktop.app/Contents/MacOS/Docker Desktop"
              ];
              KeepAlive = false;
              RunAtLoad = true;
            };
          };

          homebrew = {
            enable = true;
            brews = [
              "cowsay"
              "uv"
            ];
            taps = [ ];
            casks = [
              "docker"
              "font-fira-code"
              "font-fira-mono"
              "font-fira-mono-for-powerline"
              "font-fira-sans"
              "font-hack-nerd-font"
              "google-chrome"
              "slack"
            ];
          };

          security.sudo.extraConfig = ''
            jklapacz ALL = (ALL) NOPASSWD: ALL
          '';

        };

      homeconfig =
        { pkgs, lib, ... }:
        {
          home.stateVersion = "23.05";
          # Let home-manager install and manage itself.
          programs.home-manager.enable = true;

          home.packages = with pkgs; [
            pkgs.hello
            openssh
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

          programs.vscode = {
            enable = true;
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
      darwinConfigurations."Shadowfax" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          mac-app-util.darwinModules.default
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.verbose = true;
            home-manager.users.jklapacz = homeconfig;
            home-manager.sharedModules = [
              mac-app-util.homeManagerModules.default
            ];
          }
        ];
      };
    };
}
