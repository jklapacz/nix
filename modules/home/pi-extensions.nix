{ config, lib, ... }:

let
  # Resolve extensions at evaluation time (for the source list) but use the
  # repo checkout path at activation time so that edits take effect without
  # a rebuild.  Assumes the repo lives at ~/.config/nix.
  extSrcDir = toString ../pi/extensions;
  extTargetDir = config.home.homeDirectory + "/.config/nix/modules/pi/extensions";
  extensions = builtins.attrNames (
    lib.filterAttrs
      (name: type: type == "regular" && lib.hasSuffix ".ts" name)
      (builtins.readDir (/. + extSrcDir))
  );
in
{
  home.activation.linkPiExtensions = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    let
      mkLink = name: ''
        target_dir="${config.home.homeDirectory}/.pi/agent/extensions"
        mkdir -p "$target_dir"
        ln -sf "${extTargetDir}/${name}" "$target_dir/${name}"
      '';
    in
    builtins.concatStringsSep "\n" (map mkLink extensions)
  );
}
