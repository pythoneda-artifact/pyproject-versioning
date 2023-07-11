{
  description = "Versioning of pyproject.toml files in artifact space";

  inputs = rec {
    nixos.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    pythoneda-base = {
      url = "github:pythoneda/base/0.0.1a16";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
    };
    pythoneda-artifact-shared-nix-flakes = {
      url = "github:pythoneda-artifact-shared/nix-flakes/0.0.1a1";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-base.follows = "pythoneda-base";
    };
    pythoneda-artifact-event-versioning = {
      url = "github:pythoneda-artifact-event/versioning/0.0.1a1";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-base.follows = "pythoneda-base";
    };
  };
  outputs = inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixos { inherit system; };
        pname = "pythoneda-artifact-pyproject-versioning";
        description = "Versioning of pyproject.toml files in artifact space";
        license = pkgs.lib.licenses.gpl3;
        homepage = "https://github.com/pythoneda-artifact/pyproject-versioning";
        maintainers = with pkgs.lib.maintainers; [ ];
        nixpkgsRelease = "nixos-23.05";
        shared = import ./nix/shared.nix;
        pythonpackage = "pythonedaartifactpyprojectversioning";
        pythoneda-artifact-pyproject-versioning-for = { version, pythoneda-base
          , pythoneda-artifact-shared-nix-flakes
          , pythoneda-artifact-event-versioning, python }:
          let
            pythonVersionParts = builtins.splitVersion python.version;
            pythonMajorVersion = builtins.head pythonVersionParts;
            pythonMajorMinorVersion =
              "${pythonMajorVersion}.${builtins.elemAt pythonVersionParts 1}";
            pnameWithUnderscores =
              builtins.replaceStrings [ "-" ] [ "_" ] pname;
            wheelName =
              "${pnameWithUnderscores}-${version}-py${pythonMajorVersion}-none-any.whl";
          in python.pkgs.buildPythonPackage rec {
            inherit pname version;
            projectDir = ./.;
            src = ./.;
            format = "pyproject";

            nativeBuildInputs = with python.pkgs; [ pip pkgs.jq poetry-core ];
            propagatedBuildInputs = with python.pkgs; [
              pythoneda-artifact-event-versioning
              pythoneda-artifact-shared-nix-flakes
              pythoneda-base
            ];

            checkInputs = with python.pkgs; [ pytest ];

            pythonImportsCheck = [ pythonpackage ];

            preBuild = ''
              python -m venv .env
              source .env/bin/activate
              pip install ${pythoneda-base}/dist/pythoneda_base-${pythoneda-base.version}-py${pythonMajorVersion}-none-any.whl
              pip install ${pythoneda-artifact-event-versioning}/dist/pythoneda_artifact_event_versioning-${pythoneda-artifact-event-versioning.version}-py${pythonMajorVersion}-none-any.whl
              pip install ${pythoneda-artifact-shared-nix-flakes}/dist/pythoneda_artifact_shared_nix_flakes-${pythoneda-artifact-shared-nix-flakes.version}-py${pythonMajorVersion}-none-any.whl
              rm -rf .env
            '';

            postInstall = ''
              mkdir $out/dist
              ls dist/*
              cp dist/${wheelName} $out/dist
              jq ".url = \"$out/dist/${wheelName}\"" $out/lib/python${pythonMajorMinorVersion}/site-packages/${pnameWithUnderscores}-${version}.dist-info/direct_url.json > temp.json && mv temp.json $out/lib/python${pythonMajorMinorVersion}/site-packages/${pnameWithUnderscores}-${version}.dist-info/direct_url.json
            '';

            meta = with pkgs.lib; {
              inherit description homepage license maintainers;
            };
          };
        pythoneda-artifact-pyproject-versioning-0_0_1a2-for = { pythoneda-base
          , pythoneda-artifact-event-versioning
          , pythoneda-artifact-shared-nix-flakes, python }:
          pythoneda-artifact-pyproject-versioning-for {
            version = "0.0.1a2";
            inherit pythoneda-base pythoneda-artifact-shared-nix-flakes
              pythoneda-artifact-event-versioning python;
          };
      in rec {
        packages = rec {
          pythoneda-artifact-pyproject-versioning-0_0_1a2-python38 =
            pythoneda-artifact-pyproject-versioning-0_0_1a2-for {
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python38;
              pythoneda-artifact-event-versioning =
                pythoneda-artifact-event-versioning.packages.${system}.pythoneda-artifact-event-versioning-latest-python38;
              pythoneda-artifact-shared-nix-flakes =
                pythoneda-artifact-shared-nix-flakes.packages.${system}.pythoneda-artifact-shared-nix-flakes-latest-python38;
              python = pkgs.python38;
            };
          pythoneda-artifact-pyproject-versioning-0_0_1a2-python39 =
            pythoneda-artifact-pyproject-versioning-0_0_1a2-for {
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python39;
              pythoneda-artifact-event-versioning =
                pythoneda-artifact-event-versioning.packages.${system}.pythoneda-artifact-event-versioning-latest-python39;
              pythoneda-artifact-shared-nix-flakes =
                pythoneda-artifact-shared-nix-flakes.packages.${system}.pythoneda-artifact-shared-nix-flakes-latest-python39;
              python = pkgs.python39;
            };
          pythoneda-artifact-pyproject-versioning-0_0_1a2-python310 =
            pythoneda-artifact-pyproject-versioning-0_0_1a2-for {
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python310;
              pythoneda-artifact-event-versioning =
                pythoneda-artifact-event-versioning.packages.${system}.pythoneda-artifact-event-versioning-latest-python310;
              pythoneda-artifact-shared-nix-flakes =
                pythoneda-artifact-shared-nix-flakes.packages.${system}.pythoneda-artifact-shared-nix-flakes-latest-python310;
              python = pkgs.python310;
            };
          pythoneda-artifact-pyproject-versioning-latest-python38 =
            pythoneda-artifact-pyproject-versioning-0_0_1a2-python38;
          pythoneda-artifact-pyproject-versioning-latest-python39 =
            pythoneda-artifact-pyproject-versioning-0_0_1a2-python39;
          pythoneda-artifact-pyproject-versioning-latest-python310 =
            pythoneda-artifact-pyproject-versioning-0_0_1a2-python310;
          pythoneda-artifact-pyproject-versioning-latest =
            pythoneda-artifact-pyproject-versioning-latest-python310;
          default = pythoneda-artifact-pyproject-versioning-latest;
        };
        defaultPackage = packages.default;
        devShells = rec {
          pythoneda-artifact-pyproject-versioning-0_0_1a2-python38 =
            shared.devShell-for {
              package =
                packages.pythoneda-artifact-pyproject-versioning-0_0_1a2-python38;
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python38;
              python = pkgs.python38;
              inherit pkgs nixpkgsRelease;
            };
          pythoneda-artifact-pyproject-versioning-0_0_1a2-python39 =
            shared.devShell-for {
              package =
                packages.pythoneda-artifact-pyproject-versioning-0_0_1a2-python39;
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python39;
              python = pkgs.python39;
              inherit pkgs nixpkgsRelease;
            };
          pythoneda-artifact-pyproject-versioning-0_0_1a2-python310 =
            shared.devShell-for {
              package =
                packages.pythoneda-artifact-pyproject-versioning-0_0_1a2-python310;
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python310;
              python = pkgs.python310;
              inherit pkgs nixpkgsRelease;
            };
          pythoneda-artifact-pyproject-versioning-latest-python38 =
            pythoneda-artifact-pyproject-versioning-0_0_1a2-python38;
          pythoneda-artifact-pyproject-versioning-latest-python39 =
            pythoneda-artifact-pyproject-versioning-0_0_1a2-python39;
          pythoneda-artifact-pyproject-versioning-latest-python310 =
            pythoneda-artifact-pyproject-versioning-0_0_1a2-python310;
          pythoneda-artifact-pyproject-versioning-latest =
            pythoneda-artifact-pyproject-versioning-latest-python310;
          default = pythoneda-artifact-pyproject-versioning-latest;

        };
      });
}
