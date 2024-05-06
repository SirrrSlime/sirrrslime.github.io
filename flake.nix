{
  description = "flake for a simple website";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        devShells.default = pkgs.mkShell {
          packages = [ pkgs.zola ];
        };

        packages.website = pkgs.runCommand "build-website" { } '' 
          mkdir tmp
          cp -rf ${./.}/* tmp
          cd tmp
          ${pkgs.zola}/bin/zola build --output-dir $out
        '';

        packages.default = pkgs.writeShellScriptBin "copy-to-docs" '' 
          rm -rf docs
          mkdir -p docs
          cp -rf ${self'.packages.website}/* docs
        '';
      };
    };
}
