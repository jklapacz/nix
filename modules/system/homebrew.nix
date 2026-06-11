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
    ];
    brews = [
      "helix"
      "ipatool"
      "beads"
    ];
    casks = [
      "android-studio"
      "arc"
      "caffeine"
      "claude"
      "deskpad"
      "docker-desktop"
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
