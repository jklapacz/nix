{
  pkgs,
  lib,
  ...
}:
{
  claude = pkgs.callPackage ./package.nix { };
}
