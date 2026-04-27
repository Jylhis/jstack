# Default skill sets — batteries-included skill collections for consumers.
#
# Usage in a consumer's configuration:
#   programs.jstack.skills = jstack.lib.defaultSkills.all;
#   # or selectively:
#   programs.jstack.skills = jstack.lib.defaultSkills.nix
#     // jstack.lib.defaultSkills.python
#     // jstack.lib.defaultSkills.typescript;
#
# Each group maps skill names to { src = <path>; } attrsets.
# The `all` attribute merges all groups.
#
# These reference paths relative to this file's location (../skills/<name>),
# so only skills that live IN THIS REPO under `skills/` belong here.
# Skills bundled from upstream repositories (golang, rust, obsidian,
# promptfoo, trailofbits, …) flow in through `bundled-sources.nix` /
# `programs.jstack.skillSources` instead and must NOT be listed here,
# since their source paths would be unresolvable relative to this file.
let
  skillsDir = ../skills;
  mkSkill = name: {
    ${name}.src = skillsDir + "/${name}";
  };
  mkSkills = names: builtins.foldl' (a: b: a // b) { } (map mkSkill names);
in
rec {
  nix = mkSkills [
    "devenv"
    "flakes"
    "home-manager"
    "nix-containers"
    "nix-darwin"
    "nix-debugging"
    "nix-hybrid"
    "nix-language"
    "nix-linting"
    "nix-performance"
    "nix-testing"
    "nixos-modules"
    "nixpkgs"
  ];

  # Only the locally-maintained Go skill lives here.
  # The broader Go catalogue is bundled from `cc-skills-golang` via
  # `bundled-sources.nix` (namespace `golang`).
  golang = mkSkills [
    "golang-modern-syntax"
  ];

  python = mkSkills [
    "python-async"
    "python-code-style"
    "python-dataclasses-pydantic"
    "python-error-handling"
    "python-formatting"
    "python-linting"
    "python-packaging"
    "python-security"
    "python-testing"
    "python-type-hints"
  ];

  typescript = mkSkills [
    "typescript-async"
    "typescript-code-style"
    "typescript-error-handling"
    "typescript-formatting"
    "typescript-linting"
    "typescript-nodejs-patterns"
    "typescript-packaging"
    "typescript-security"
    "typescript-testing"
    "typescript-type-system"
  ];

  jvm = mkSkills [
    "java-code-style"
    "java-concurrency"
    "jvm-build-gradle"
    "jvm-packaging"
    "jvm-security"
    "jvm-testing"
    "kotlin-code-style"
    "kotlin-coroutines"
  ];

  emacs = mkSkills [
    "elisp-conventions"
    "elisp-major-mode-authoring"
    "elisp-package-publishing"
    "elisp-review"
    "elisp-testing"
    "emacs-debugging"
    "emacs-gptel-integration"
    "emacs-introspection"
    "emacs-keybindings"
    "emacs-nix-packaging"
  ];

  claude-ecosystem = mkSkills [
    "claude-api"
    "mcp-builder"
  ];

  gitlab = mkSkills [
    "gitlab-cicd"
    "glab"
  ];

  storage = mkSkills [
    "apfs"
    "btrfs"
    "zfs"
  ];

  misc = mkSkills [
    "offline-docs"
    "using-skills"
  ];

  productivity = mkSkills [
    "session-log"
  ];

  skill-creator = mkSkills [
    "skill-creator"
    "skill-creator-lang"
  ];

  # All local skills merged into a single attrset.
  all =
    nix
    // golang
    // python
    // typescript
    // jvm
    // emacs
    // claude-ecosystem
    // gitlab
    // storage
    // misc
    // productivity
    // skill-creator;
}
