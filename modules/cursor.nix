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

  makeInstallScript =
    extensions:
    let
      cursorPath = cfg.package;
      installedExts = ''$(${cursorPath} --list-extensions)'';

      installCmds = map (ext: ''
        if ! echo "$installedExts" | grep -q "^${ext}$"; then
          echo "Installing Cursor extension: ${ext}"
          ${cursorPath} --install-extension "${ext}"
        fi
      '') extensions;
    in
    pkgs.writeShellScript "install-cursor-extensions" ''
      set -e
      if [ ! -x "${cursorPath}" ]; then
        echo "Error: Cursor not found at ${cursorPath}"
        exit 1
      fi
      ${concatStringsSep "\n" installCmds}
    '';

in
{
  options.programs.cursor = {
    enable = mkEnableOption "Cursor extension management";

    package = mkOption {
      type = types.str;
      description = "Path to the Cursor executable";
    };

    extensions = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [
        "vscodevim.vim"
        "ms-python.python"
      ];
      description = "List of Cursor extensions to install";
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

    home.activation.installCursorExtensions = hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD ${makeInstallScript cfg.extensions}
    '';

    # Add settings.json management
    home.file."${cfg.userDir}/settings.json".source = toJSON cfg.settings;
  };
}
