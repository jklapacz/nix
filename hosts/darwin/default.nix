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
}
