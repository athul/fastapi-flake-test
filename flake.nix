{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, poetry2nix }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) mkPoetryApplication;
      inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) overrides;

      app = mkPoetryApplication {
        projectDir = ./.;
        preferWheels = true;
        overrides = overrides.withDefaults (self: super: {
          watchfiles = super.watchfiles.override {
            preferWheel = false;
          };
        });
      };

      dockerImage = pkgs.dockerTools.buildLayeredImage {
        name = "base_api";
        tag = "latest";
        contents = [ app.dependencyEnv pkgs.bashInteractive pkgs.python3 pkgs.poetry ];
        # copyToRoot = pkgs.buildEnv {
        #   name = "base";
        #   paths = [ pkgs.bashInteractive pkgs.poetry pkgs.python3 ];
        #   # after = pkgs.poetry.install { };
        # };
        extraCommands = ''
          pwd
          ls
          ls ${app}
        '';
        config = {
          WorkingDir = "./";
          Cmd = [ "${app.dependencyEnv}/bin/uvicorn" "base_api.main:app" ];
          ExposedPorts = {
            "8000/tcp" = { };
          };
        };
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
