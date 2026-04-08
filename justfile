default:
    @just --list --justfile {{justfile()}}

# Regenerate settings.json from settings.nix
generate-settings:
    nix eval --impure --json --expr 'import ./settings.nix' | jq -S . > settings.json

lint:
    devenv shell -- lint

install *args:
    bash scripts/install.bash {{args}}

eval *args:
    bash scripts/eval.bash {{args}}

eval-fast *args:
    bash scripts/eval.bash --fast {{args}}
