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
        experimental-features = ["nix-command" "flakes"];
        max-jobs = "auto";
        bash-prompt-prefix = "(nix:$name)\040";
        netrc-file = "/nix/var/determinate/netrc";
        post-build-hook = "/nix/var/determinate/post-build-hook.sh";
        always-allow-substitutes = true;
        extra-substituters = ["https://cache.flakehub.com"];
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
        pkgs.neofetch
        pkgs.neovim
      ];

      security.pam.enableSudoTouchIdAuth = true;

    };
  in
  {
    darwinConfigurations."Shadowfax" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
