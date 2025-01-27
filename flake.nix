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
          mkdir -p $out/assets
          cp -r assets/*  $out/assets
          cp -r install.sh $out/bin
          cp -r uninstall.sh $out/bin
	  touch $out/bin/.bashrc
## existing install script modified to fit nixos (change installdir and bashrc location.)


INSTALL_DIR="$out/bin"
BASHRC="$out/bin/.bashrc"
# file containing command definitions:
SHUNPO_CMD="$INSTALL_DIR/shunpo_cmd"

setup() {
    mkdir -p $INSTALL_DIR
    if [ -f $SHUNPO_CMD ]; then
        rm $SHUNPO_CMD
    fi
    touch $SHUNPO_CMD
}

add_commands() {
    INSTALL_DIR="$(realpath "$INSTALL_DIR")"

    functions=(
        "sj() { source \"$INSTALL_DIR/jump_to_parent.sh\"; }"
        "sd() { source \"$INSTALL_DIR/jump_to_child.sh\"; }"
        "sb() { \"$INSTALL_DIR/add_bookmark.sh\" \"\$@\"; }"
        "sr() { \"$INSTALL_DIR/remove_bookmark.sh\" \"\$@\"; }"
        "sg() { source \"$INSTALL_DIR/go_to_bookmark.sh\"; }"
        "sl() { \"$INSTALL_DIR/list_bookmarks.sh\"; }"
        "sc() { \"$INSTALL_DIR/clear_bookmarks.sh\"; }"
    )

    for func_definition in "$\{functions[@]}"; do
        echo "$func_definition" >>"$SHUNPO_CMD"
        echo "Created Command: $\{func_definition%%()*}"
    done
}

install() {
    cp src/* $INSTALL_DIR

    # add sourcing for .shunporc
    source_rc_line="source $SHUNPO_CMD"
    temp_file=$(mktemp)
    sed '/^source.*\.shunporc/d' "$BASHRC" >"$temp_file"
    mv "$temp_file" "$BASHRC"
    echo "$source_rc_line" >>"$BASHRC"
    echo "Added to BASHRC: $source_rc_line"

    # record SHUNPO_DIR for uninstallation.
    install_dir_line="export SHUNPO_DIR=$INSTALL_DIR" >>"$BASHRC$"
    temp_file=$(mktemp)
    grep -v '^export SHUNPO_DIR=' "$BASHRC" >"$temp_file"
    mv "$temp_file" "$BASHRC"
    echo "$install_dir_line" >>"$BASHRC"
    echo "Added to BASHRC: $install_dir_line"

    add_commands
}

# Install.
echo "Installing."
setup
install

echo "Done."
echo "(Remember to run source ~/.bashrc.)"


        '';
      };

      checks.x86_64-linux.tests = pkgs.runCommand "shunpo-tests" {
        buildInputs = [ pkgs.bash pkgs.bats ];
      } ''
        bats tests/
      '';

      devShell.x86_64-linux = pkgs.mkShell {
        buildInputs = [ pkgs.bash pkgs.shfmt pkgs.bats ];
        inputsFrom = [ self.packages.x86_64-linux.default ];
	shellHook = ''
	    source ${self.packages.x86_64-linux.default}/bin/.bashrc
	  '';
	};
    };
}
