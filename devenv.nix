{ pkgs, ... }:
{
  packages = with pkgs; [
    git
    just
    jq
    shellcheck
    (python3.withPackages (ps: with ps; [ pyyaml jsonschema ]))
    nodejs_22
  ];

  enterShell = ''
    echo "skills dev shell — see 'just' for available recipes"
    if ! command -v promptfoo >/dev/null 2>&1; then
      echo "note: promptfoo not on PATH. Install via 'npm i -g promptfoo' for live evals."
    fi
  '';

  languages = {
    nix.enable = true;
    shell.enable = true;
    python.enable = true;
  };

  enterTest = ''
    set -e
    shellcheck scripts/install.sh
    shellcheck evals/providers/*.sh evals/judges/*.sh
    python3 scripts/validate.py
    just eval-smoke
  '';
}
