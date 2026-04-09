default:
    @just --list --justfile {{justfile()}}

# Regenerate settings.json from settings.nix
generate-settings:
    nix eval --impure --json --expr 'import ./settings.nix' | jq -S . > settings.json

# Generate all manifests (plugin.json, .mcp.json, .lsp.json) from plugin.nix
generate-manifests:
    @for dir in plugins/*/; do \
      dir="${dir%/}"; \
      name=$(basename "$dir"); \
      [ -f "$dir/plugin.nix" ] || continue; \
      echo "Generating manifests for $name..."; \
      manifest=$( \
        nix eval --impure --json --expr " \
          let pkgs = import ./npins {}; p = import ./$dir/plugin.nix { inherit pkgs; }; \
          in { inherit (p) name description; } \
            // (if p ? version then { inherit (p) version; } else {}) \
            // { author = p.author or {}; } \
        " \
      ); \
      mkdir -p "$dir/.claude-plugin"; \
      echo "$manifest" | jq -S . > "$dir/.claude-plugin/plugin.json"; \
      mcp=$( \
        nix eval --impure --json --expr " \
          let pkgs = import ./npins {}; p = import ./$dir/plugin.nix { inherit pkgs; }; \
          in if p ? mcpServers && p.mcpServers != {} then { mcpServers = p.mcpServers; } else null \
        " \
      ); \
      [ "$mcp" != "null" ] && echo "$mcp" | jq -S . > "$dir/.mcp.json"; \
      lsp=$( \
        nix eval --impure --json --expr " \
          let pkgs = import ./npins {}; p = import ./$dir/plugin.nix { inherit pkgs; }; \
          in if p ? lspServers && p.lspServers != {} then p.lspServers else null \
        " \
      ); \
      [ "$lsp" != "null" ] && echo "$lsp" | jq -S . > "$dir/.lsp.json"; \
    done
    @echo "Done."

# List all discovered skills from local plugins and third-party sources
list-skills:
    nix eval --impure --json --expr 'import ./lib/list-catalog.nix' | jq .

# Add a third-party skill source via npins
add-source owner repo:
    npins add github {{owner}} {{repo}}
    @echo "Pin added. Edit sources.nix to configure namespace and discovery."

# Format all project files via treefmt
fmt:
    treefmt

# Check formatting, lint, and run devenv test suite
check:
    devenv test

lint:
    devenv shell -- lint

install *args:
    bash scripts/install.bash {{args}}

# Install for a specific target (claude, codex, gemini, all)
install-target target *args:
    bash scripts/install.bash --target {{target}} {{args}}

eval *args:
    bash scripts/eval.bash {{args}}

eval-fast *args:
    bash scripts/eval.bash --fast {{args}}

# Run quality evals only (llm-rubric assertions)
eval-quality *args:
    bash scripts/eval.bash --quality {{args}}

# Run evals for a specific skill (matches test description)
eval-skill skill *args:
    bash scripts/eval.bash --skill {{skill}} {{args}}

# Run evals for a specific plugin
eval-plugin plugin *args:
    bash scripts/eval.bash --plugin {{plugin}} {{args}}

# Compare routing results across Claude and GPT-4o
eval-compare *args:
    bash scripts/eval.bash --compare {{args}}

# Run adversarial/redteam tests
eval-redteam *args:
    bash scripts/eval.bash --redteam {{args}}
