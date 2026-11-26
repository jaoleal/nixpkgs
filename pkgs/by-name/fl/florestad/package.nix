{
  lib,
  rustPlatform,
  fetchFromGitHub,
  boost,
  cmake,
  pkg-config,
  versionCheckHook,
  zstd,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "florestad";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "getfloresta";
    repo = "Floresta";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gsWYRqOHrCD5G5xdlQnfUpKvZNcHDUHiuayLof03wNE=";
  };

  cargoHash = "sha256-MeTrPoJVgoaSaNGq5RuZUAtmCY7/8gMUKmcclFZ+Y5U=";
  __structuredAttrs = true;

  nativeBuildInputs = [
    # libbitcoinkernel-sys compiles the Bitcoin Core kernel it vendors
    cmake
    # zstd-sys, a dev-dependency of the chain, wire and electrum crates, probes
    # for a system libzstd when the test build pulls it in
    pkg-config
  ];

  buildInputs = [
    boost
    zstd
  ];

  # Bitcoin Core looks Boost up in CMake config mode. Cargo runs CMake itself,
  # so the cmake setup hook's search path never reaches it.
  env.CMAKE_PREFIX_PATH = "${lib.getDev boost}";

  cargoBuildFlags = [ "--package=florestad" ];

  cargoTestFlags = [
    "--workspace"
    # bin/floresta-cli/src/main.rs asserts that floresta-rpc's `async` feature
    # is off, and sharing a cargo invocation with florestad unifies features
    # and turns it on. The floresta-cli package builds that binary on its own.
    "--exclude=floresta-cli"
    # cargo-fuzz harness, built by `cargo fuzz` on a nightly toolchain
    "--exclude=floresta-fuzz"
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Lightweight and embeddable Bitcoin full node using Utreexo";
    homepage = "https://github.com/getfloresta/Floresta";
    changelog = "https://github.com/getfloresta/Floresta/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [
      mit
      asl20
    ];
    maintainers = with lib.maintainers; [ jaoleal ];
    mainProgram = "florestad";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
