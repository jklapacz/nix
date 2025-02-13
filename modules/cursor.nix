{ config, lib, ... }:

with lib;

let
  cfg = config.programs.cursor;

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
  };
}
