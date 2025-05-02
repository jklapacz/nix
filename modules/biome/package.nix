{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  libgit2,
  rust-jemalloc-sys,
  zlib,
  gitMinimal,
}:
rustPlatform.buildRustPackage rec {
  pname = "biome";
  version = "2.0.0-beta.2";

  src = fetchFromGitHub {
    owner = "biomejs";
    repo = "biome";
    rev = "@biomejs/biome@${version}";
    hash = "sha256-ecI+9+PETvB1GDs2S8AjtiVw8vT83ntAlI/5H4taSKM=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-7i9KqrYYalDGvPWpp7UA7MNIEQklVwc3RkW77a9M/Z4=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libgit2
    rust-jemalloc-sys
    zlib
  ];

  nativeCheckInputs = [ gitMinimal ];

  cargoBuildFlags = [ "-p=biome_cli" ];
  cargoTestFlags = cargoBuildFlags ++ [
    "-- --skip=commands::check::print_json"
    "--skip=commands::check::print_json_pretty"
    "--skip=commands::explain::explain_logs"
    "--skip=commands::format::print_json"
    "--skip=commands::format::print_json_pretty"
    "--skip=commands::format::should_format_files_in_folders_ignored_by_linter"
  ];

  env = {
    BIOME_VERSION = version;
    LIBGIT2_NO_VENDOR = 1;
  };

  preCheck = ''
    # tests assume git repository
    git init

    # tests assume $BIOME_VERSION is unset
    unset BIOME_VERSION
  '';

  meta = {
    description = "Toolchain of the web";
    homepage = "https://biomejs.dev/";
    changelog = "https://github.com/biomejs/biome/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      figsoda
      isabelroses
    ];
    mainProgram = "biome";
  };
}
