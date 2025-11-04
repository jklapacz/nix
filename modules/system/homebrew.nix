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
      "trycua/lume"
    ];
    brews = [
      "lume"
    ];
    casks = [
      "arc"
      "caffeine"
      "cursor"
      "claude"
      "deskpad"
      "docker"
      "firefox"
      "google-chrome"
      "moom"
      "slack"
      "visual-studio-code"
      "postman"
    ];
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
  };
}
