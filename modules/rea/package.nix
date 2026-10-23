{
  lib,
  buildNpmPackage,
  fetchzip,
  makeWrapper,
  nodejs_24,
  ghidra,
  openjdk21,
}:

buildNpmPackage rec {
  pname = "rea-agents";
  version = "6.4.0";

  nodejs = nodejs_24; # requires ^22.19 || ^24.11 || >=26

  src = fetchzip {
    url = "https://registry.npmjs.org/rea-agents/-/rea-agents-${version}.tgz";
    hash = "sha256-aJTYn9CZchdwJLBMn9no4C2EGBO6XemsH3J0GU1DqWM=";
  };

  npmDepsHash = "sha256-aMD66LEDaVjyDrdaaSQA2FjdAUltdj+RZH8W8xNIdNo=";

  nativeBuildInputs = [ makeWrapper ];

  # The published package.json lists devDependencies and dev scripts, so use a
  # copy stripped to runtime dependencies (see update.sh) that matches the lock.
  postPatch = ''
    cp ${./package.json} package.json
    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  # Point REA's Ghidra provider at the nixpkgs Ghidra (needs the base install,
  # not the withExtensions wrapper) and a JDK it accepts. --set-default lets an
  # explicit environment still override these.
  postInstall = ''
    for prog in rea rea-agents; do
      wrapProgram $out/bin/$prog \
        --set-default GHIDRA_INSTALL_DIR ${ghidra}/lib/ghidra \
        --set-default JAVA_HOME ${openjdk21.home}
    done
  '';

  meta = {
    description = "Reverse-engineering MCP server and CLI for coding agents";
    homepage = "https://github.com/morluto/rea";
    downloadPage = "https://www.npmjs.com/package/rea-agents";
    license = lib.licenses.mit;
    mainProgram = "rea";
  };
}
