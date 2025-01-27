{
  description = "Shunpo: A minimalist bash tool for quick directory navigation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in
    {
      packages.x86_64-linux.default = pkgs.stdenv.mkDerivation {
        name = "shunpo";
        src = ./.;
        buildInputs = [ pkgs.bash pkgs.shfmt pkgs.bats ];
        installPhase = ''
          mkdir -p $out/bin
          cp -r * $out/bin
        '';
      };

      checks.x86_64-linux.tests = pkgs.runCommand "shunpo-tests" {
        buildInputs = [ pkgs.bash pkgs.bats ];
      } ''
        bats tests/
      '';

      devShell.x86_64-linux = pkgs.mkShell {
        buildInputs = [ pkgs.bash pkgs.shfmt pkgs.bats ];
      };
    };
}
