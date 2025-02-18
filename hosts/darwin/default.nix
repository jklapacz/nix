{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}:
let
  user = "jklapacz";
in
{
  imports = [
    ../../dock
  ];

  local = {
    dock.enable = true;
    dock.entries = [
      { path = "/Applications/Slack.app"; }
      { path = "/Applications/Google Chrome.app"; }
      { path = "/Applications/Safari.app"; }
      { path = "${pkgs.wezterm}/Applications/WezTerm.app"; }
      { path = "/Applications/Cursor.app"; }
      { path = "/Applications/Visual Studio Code.app"; }
      { path = "/Applications/Claude.app"; }
    ];
  };

  system.defaults = {
    CustomUserPreferences = {
      "com.cursor.app" = {
        ApplePressAndHoldEnabled = false;
      };
      # "com.apple.Safari" = {
      #   IncludeDevelopMenu = true;
      #   WebKitDeveloperExtrasEnabledPreferenceKey = true;
      #   "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;
      # };
    };

    NSGlobalDomain = {
      # Key input speed
      InitialKeyRepeat = 20;
      KeyRepeat = 1;

      # UI/UX
      ApplePressAndHoldEnabled = false;
      NSNavPanelExpandedStateForSaveMode = true;
      PMPrintingExpandedStateForPrint = true;
      NSDocumentSaveNewDocumentsToCloud = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      AppleShowAllExtensions = true;
      "com.apple.springing.enabled" = true;
      "com.apple.springing.delay" = 0.1;
    };

    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = true;
    };

    finder = {
      AppleShowAllExtensions = true;
      _FXShowPosixPathInTitle = true;
      FXDefaultSearchScope = "SCcf";
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";
      ShowPathbar = true;
      ShowStatusBar = true;
      QuitMenuItem = true;
    };

    dock = {
      autohide = false;
      show-recents = false;
      tilesize = 30;
      showhidden = true;
      expose-animation-duration = 0.15;
      wvous-br-corner = 2;
      wvous-tr-corner = 10;
      wvous-bl-corner = 4;
    };

    screencapture = {
      location = "~/Downloads";
      type = "png";
      disable-shadow = true;
    };
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };
}
