{
  config,
  lib,
  pkgs,
  ...
}:

{
  homebrew = {
    enable = true;
    taps = [
      "homebrew/homebrew-core"
      "homebrew/homebrew-cask"
      "homebrew/homebrew-bundle"
      "shayanabbas1/dbdelve"
    ];
    brews = [
      "helix"
      "ipatool"
      "beads"
      "llama.cpp"
    ];
    casks = [
      "android-studio"
      "arc"
      "caffeine"
      "shayanabbas1/dbdelve/dbdelve"
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

  # Runs after the homebrew activation step. Strips Gatekeeper quarantine from
  # casks that aren't notarized (Homebrew no longer supports --no-quarantine).
  system.activationScripts.postActivation.text = ''
    if [ -d "/Applications/DBDelve.app" ]; then
      /usr/bin/xattr -dr com.apple.quarantine "/Applications/DBDelve.app" 2>/dev/null || true
    fi
  '';
}
