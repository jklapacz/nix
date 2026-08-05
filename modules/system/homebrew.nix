{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Homebrew 6 refuses to load formulae from third-party taps unless trusted
  # via `brew trust`. Trust is per-user state (~/.homebrew/trust.json) and the
  # homebrew activation script runs `brew bundle` as jklapacz, so establish
  # trust as that user before it runs. brew refuses to run as root, hence the
  # explicit sudo drop.
  system.activationScripts.preActivation.text = ''
    if [ -x /opt/homebrew/bin/brew ]; then
      sudo --user=jklapacz --set-home /opt/homebrew/bin/brew trust cirruslabs/cli \
        || echo >&2 "warning: brew trust cirruslabs/cli failed"
    fi
  '';

  homebrew = {
    enable = true;
    taps = [
      "homebrew/homebrew-core"
      "homebrew/homebrew-cask"
      "homebrew/homebrew-bundle"
      "cirruslabs/cli"
    ];
    brews = [
      "helix"
      "ipatool"
      "beads"
      "cirruslabs/cli/tart"
    ];
    casks = [
      "android-studio"
      "arc"
      "caffeine"
      "claude"
      "deskpad"
      "orbstack"
      "firefox"
      "google-chrome"
      "moom"
      "slack"
      "visual-studio-code"
      "ghostty"
      "postman"
      "wireshark-app"
    ];
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
  };
}
