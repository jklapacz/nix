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
    ];
    casks = [
      "android-studio"
      "arc"
      "caffeine"
      "cursor"
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
    ];
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
  };
}
