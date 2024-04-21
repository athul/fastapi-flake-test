{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      dockerImage = pkgs.dockerTools.buildImage {
        name = "fastapi-nix-test";
        tag = "latest";
        # contents = [ pkgs.bashInteractive pkgs.python3 pkgs.poetry ];
        copyToRoot = pkgs.buildEnv {
          name = "base";
          paths = [ pkgs.bashInteractive pkgs.poetry pkgs.python3 ];
          # after = pkgs.poetry.install { };
        };
        # extraCommands = ''
        #   poetry install --no-interaction
        #
        # '';
        config = {
          Cmd = [ "poetry run uvicorn main:app --reload" ];
        };
        # ExposedPorts = {
        #   "8000/tcp" = { };
        # };
      };
    in
    {
      packages.x86_64-linux.default = dockerImage;
      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = [
          pkgs.bashInteractive
          pkgs.poetry
          pkgs.python3
        ];
        shellHook = ''
          echo "Initializing Python env"
          poetry lock
          poetry shell
        '';
      };
    };
}
