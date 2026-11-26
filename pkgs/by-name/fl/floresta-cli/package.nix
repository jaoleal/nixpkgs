{
  lib,
  rustPlatform,
  versionCheckHook,
  florestad,
}:

rustPlatform.buildRustPackage {
  pname = "floresta-cli";
  # bin/floresta-cli/Cargo.toml is versioned independently of the Floresta
  # release that florestad tracks.
  version = "0.6.0";
  inherit (florestad) src cargoDeps;
  __structuredAttrs = true;

  # bin/floresta-cli/src/main.rs asserts that floresta-rpc's `async` feature is
  # off, and sharing a cargo invocation with florestad unifies features and
  # turns it on, so this binary gets an invocation of its own.
  cargoBuildFlags = [ "--package=floresta-cli" ];
  cargoTestFlags = [ "--package=floresta-cli" ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  meta = {
    description = "Command-line client for the Floresta Bitcoin node";
    homepage = "https://github.com/getfloresta/Floresta";
    changelog = "https://github.com/getfloresta/Floresta/releases/tag/v${florestad.version}";
    license = with lib.licenses; [
      mit
      asl20
    ];
    maintainers = with lib.maintainers; [ jaoleal ];
    mainProgram = "floresta-cli";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
