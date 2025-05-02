{
  pkgs,
  lib,
  ...
}:
{
  biome = pkgs.callPackage ./package.nix { };
}
