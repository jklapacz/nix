# modules/cursor.nix
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.cursor;

  extensionPath = ".cursor/extensions";

  userDir =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "Library/Application Support/Cursor/User"
    else
      "${config.xdg.configHome}/Cursor/User";

  configFilePath = "${userDir}/settings2.json";

  jsonFormat = pkgs.formats.json { };

  # Helper function to generate pretty-printed JSON from nix
  toJSON =
    config:
    pkgs.runCommand "cursor-settings.json"
      {
        buildInputs = [ pkgs.jq ];
        value = builtins.toJSON config;
        passAsFile = [ "value" ];
      }
      ''
        cat $valuePath | jq '.' > $out
      '';

  # Function to get extension paths
  toPaths =
    ext:
    map (k: { "${extensionPath}/${k}-${ext.version}".source = "${ext}/share/vscode/extensions/${k}"; })
      (
        if ext ? vscodeExtUniqueId then
          [ ext.vscodeExtUniqueId ]
        else
          builtins.attrNames (builtins.readDir (ext + "/share/vscode/extensions"))
      );

  mergedUserSettings =
    cfg.userSettings
    // optionalAttrs (!cfg.enableUpdateCheck) { "update.mode" = "none"; }
    // optionalAttrs (!cfg.enableExtensionUpdateCheck) { "extensions.autoCheckUpdates" = false; };
in
{
  options.programs.cursor = {
    enable = mkEnableOption "Cursor extension management";

    package = mkOption {
      type = types.str;
      description = "Path to the Cursor executable";
    };

    extensions = mkOption {
      type = types.listOf types.package;
      default = [ ];
      example = literalExpression ''
        [
          pkgs.vscode-marketplace.jnoortheen.nix-ide
        ]
      '';
      description = "List of Cursor extensions to install";
    };

    enableUpdateCheck = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to enable update checks/notifications.
      '';
    };

    enableExtensionUpdateCheck = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to enable update notifications for extensions.
      '';
    };

    userSettings = mkOption {
      type = jsonFormat.type;
      default = { };
      example = literalExpression ''
        {
          "files.autoSave" = "off";
          "[nix]"."editor.tabSize" = 2;
        }
      '';
      description = ''
        Configuration written to Visual Studio Code's
        {file}`settings.json`.
      '';
    };

    settings = mkOption {
      type = types.attrs;
      default = { };
      example = literalExpression ''
        {
          "window.commandCenter" = 1;
          "editor.formatOnSave" = true;
          "extensions.experimental.affinity" = {
            "asvetliakov.vscode-neovim" = 1;
          };
        }
      '';
      description = "Cursor settings to write to settings.json";
    };

    userDir = mkOption {
      type = types.str;
      default = "Library/Application Support/Cursor/User";
      description = "Path to Cursor user directory (relative to home)";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.package != "";
        message = "programs.cursor.package must be set";
      }
    ];

    home.file = mkMerge [
      (mkIf (cfg.extensions != [ ]) (mkMerge (concatMap toPaths cfg.extensions)))
      (mkIf (cfg.userSettings != { }) {
        "${configFilePath}".source = jsonFormat.generate "vscode-user-settings" mergedUserSettings;
      })

      # Settings.json management
      { "${cfg.userDir}/settings.json".source = toJSON cfg.settings; }
    ];

    # Add settings.json management
  };
}
