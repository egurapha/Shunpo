{
  description = "Shunpo: A minimalist bash tool for quick directory navigation";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in f pkgs
      );
    in
    {
      packages = forAllSystems
        (pkgs: {
          default = self.packages.${pkgs.system}.shunpo;
          shunpo = pkgs.stdenv.mkDerivation {
            pname = "shunpo";
            version = "1.0.4";

            src = builtins.path { path = ../src; };
            buildInputs = [ pkgs.bash pkgs.shfmt ];

            installPhase = ''
              # Generate installation directories and files.
              INSTALL_DIR=$out/bin
              SCRIPT_DIR=$out/scripts
              mkdir -p $INSTALL_DIR
              mkdir -p $SCRIPT_DIR

              # Define commands.
              SHUNPO_CMD=$SCRIPT_DIR/shunpo_cmd
              touch $SHUNPO_CMD

              cat > "$SHUNPO_CMD" <<EOF
#!/usr/bin/env bash
sj() { source "$SCRIPT_DIR/jump_to_parent.sh" "\$@"; }
sd() { source "$SCRIPT_DIR/jump_to_child.sh"; }
sb() { "$SCRIPT_DIR/add_bookmark.sh"; }
sr() { "$SCRIPT_DIR/remove_bookmark.sh" "\$@"; }
sg() { source "$SCRIPT_DIR/go_to_bookmark.sh" "\$@"; }
sl() { "$SCRIPT_DIR/list_bookmarks.sh"; }
sc() { "$SCRIPT_DIR/clear_bookmarks.sh"; }
EOF

              # Store scripts in SCRIPTS_DIR.
              cp $src/* $SCRIPT_DIR

              # Write initialization file that must be sourced.
              SHUNPO_INIT=$INSTALL_DIR/shunpo_init
              cat > "$SHUNPO_INIT" <<'INIT_EOF'
# Create default config file if it doesn't exist.
SHUNPO_CONFIG_DIR=''${XDG_CONFIG_HOME:-$HOME/.config}/shunpo
SHUNPO_CONFIG_FILE=$SHUNPO_CONFIG_DIR/config
if [ ! -f "$SHUNPO_CONFIG_FILE" ]; then
    mkdir -p "$SHUNPO_CONFIG_DIR"
    cat >"$SHUNPO_CONFIG_FILE" <<'CONFIG_EOF'
# Shunpo Configuration
# Selection keys (exactly 10 characters, one per menu item)
# Reserved keys that cannot be used: n, p, b
# Note: CLI arguments (e.g., sg 3, sj 1) always use numeric indices 0-9
SHUNPO_SELECTION_KEYS="1234567890"
CONFIG_EOF
fi
unset SHUNPO_CONFIG_DIR SHUNPO_CONFIG_FILE
INIT_EOF
              echo "source $SHUNPO_CMD" >> "$SHUNPO_INIT"
              chmod +x $SHUNPO_INIT # not necessary, but keep for auto-complete.
            '';


            meta = {
              description = "Shunpo: A minimalist bash tool for quick directory navigation";
              license = nixpkgs.lib.licenses.mit;
              maintainers = [ "egurapha" ];
              platforms = supportedSystems;
            };
          };
        });

      devShells = forAllSystems (pkgs: {
        shunpo = pkgs.mkShell {
          buildInputs = [ pkgs.bash ];
        };
      });
    };
}
