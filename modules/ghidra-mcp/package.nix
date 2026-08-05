{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

# Prebuilt GhidraMCP extension (https://github.com/bethington/ghidra-mcp).
# The release version must target the Ghidra version shipped by nixpkgs
# (extension.properties pins version=12.1.2); bump both together.
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ghidra-mcp";
  version = "6.0.0";

  src = fetchurl {
    url = "https://github.com/bethington/ghidra-mcp/releases/download/v${finalAttrs.version}/GhidraMCP-${finalAttrs.version}.zip";
    hash = "sha256-hncx3ifVFDYyoBCUO5B6ZIXdVNDhlyni+F7p9pLJmHM=";
  };

  nativeBuildInputs = [ unzip ];
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/ghidra/Ghidra/Extensions
    unzip -d $out/lib/ghidra/Ghidra/Extensions $src

    # Prevent attempted creation of plugin lock files in the Nix store.
    touch $out/lib/ghidra/Ghidra/Extensions/GhidraMCP/.dbDirLock

    runHook postInstall
  '';

  meta = {
    description = "Ghidra extension exposing an MCP server for AI-assisted reverse engineering";
    homepage = "https://github.com/bethington/ghidra-mcp";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
})
