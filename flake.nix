{
  description = "Shadowfax system configuration";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/master";

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
    homebrew-cirruslabs = {
      url = "github:cirruslabs/homebrew-cli";
      flake = false;
    };
    mac-app-util = {
      url = "github:hraban/mac-app-util";
    };
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    devenv.url = "github:cachix/devenv";
  };

  outputs =
    inputs@{
      self,
      darwin,
      nix-homebrew,
      homebrew-bundle,
      homebrew-core,
      homebrew-cask,
      homebrew-cirruslabs,
      home-manager,
      nixpkgs,
      mac-app-util,
      nix-vscode-extensions,
      devenv,
      ...
    }:
    let
      user = "jklapacz";
      configuration =
        { pkgs, ... }:
        {
          imports = [
            ./modules/system/packages.nix
            ./modules/system/fonts.nix
            ./modules/system/homebrew.nix
          ];

          home-manager.backupFileExtension = "backup";
          system.primaryUser = "jklapacz";

          environment.etc."nix/nix.custom.conf".text = pkgs.lib.mkForce ''
            # Add nix settings to seperate conf file
            # since we use Determinate Nix on our systems.
            trusted-users = root ${user}
            extra-substituters = https://devenv.cachix.org https://nixpkgs-python.cachix.org
            extra-trusted-public-keys = nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU= devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
          '';
          nixpkgs.overlays = [
            nix-vscode-extensions.overlays.default
            (final: prev: {
              devenv = devenv.packages.${final.stdenv.hostPlatform.system}.devenv;
            })
            (final: prev: {
              customClaude = import ./modules/claude {
                pkgs = final;
                lib = final.lib;
              };
            })
          ];
          nixpkgs.config.allowUnfree = true;

          system.configurationRevision = self.rev or self.dirtyRev or null;
          system.stateVersion = 4;

          # Replace with x86_64-darwin if on Intel Mac
          nixpkgs.hostPlatform = "aarch64-darwin";

          users.users.${user} = {
            name = user;
            home = "/Users/${user}";
          };

          programs.zsh.enable = true;

          security.sudo.extraConfig = ''
            ${user} ALL = (ALL) NOPASSWD: ALL
          '';

        };

      baseHomeConfig =
        {
          pkgs,
          lib,
          hostname,
          ...
        }:
        {
          imports = [
            ./modules/home/shell.nix
            ./modules/home/dev-tools.nix
            ./modules/home/git.nix
            ./modules/home/ssh.nix
          ];

          home.stateVersion = "23.05";
          # Let home-manager install and manage itself.
          programs.home-manager.enable = true;
        };
      mkHomeConfig = hostname: { pkgs, lib, ... }: baseHomeConfig { inherit pkgs lib hostname; };
    in
    {
      darwinConfigurations."Shadowfax" = darwin.lib.darwinSystem {
        modules = [
          configuration
          mac-app-util.darwinModules.default
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
          {
            networking.hostName = "Shadowfax";
            nix = {
              enable = false;
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.verbose = true;
            home-manager.users.${user} = mkHomeConfig "Shadowfax";
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
                "cirruslabs/homebrew-cli" = homebrew-cirruslabs;
              };
              mutableTaps = true;
              autoMigrate = false;
            };
          }
          ./hosts/darwin
        ];
      };

      darwinConfigurations."Anduril" = darwin.lib.darwinSystem {
        modules = [
          configuration
          mac-app-util.darwinModules.default
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
          {
            networking.hostName = "Anduril";
            nix = {
              enable = false;
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.verbose = true;
            home-manager.users.${user} = mkHomeConfig "Anduril";
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
                "cirruslabs/homebrew-cli" = homebrew-cirruslabs;
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
