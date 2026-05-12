{ pkgs, ... }:
{
  packages = with pkgs; [
    git
    just
    jq
    shellcheck
    (python3.withPackages (ps: with ps; [ pyyaml jsonschema ]))
    promptfoo
  ];

  enterShell = ''
    echo "skills dev shell — see 'just' for available recipes"
  '';

  languages = {
    nix.enable = true;
    shell.enable = true;
    python.enable = true;
    go.enable = true;
    typescript.enable = true;
    javascript = {
      enable = true;
      bun.enable = true;
    };
  };

  enterTest = ''
    set -e
    shellcheck scripts/install.sh
    shellcheck evals/providers/*.sh evals/judges/*.sh
    python3 scripts/validate.py
    just eval-smoke
  '';
}
