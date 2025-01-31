{
  description = "Shadowfax system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      services.nix-daemon.enable = true;
      nix.settings = {
        experimental-features = "nix-command flakes";
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
      environment.systemPackages = [ ];
    };
  in
  {
    darwinConfigurations."Shadowfax" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
