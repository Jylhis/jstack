# Default skill sets — batteries-included skill collections for consumers.
#
# Usage in a consumer's configuration:
#   programs.jstack.skills = jstack.lib.defaultSkills.all;
#   # or selectively:
#   programs.jstack.skills = jstack.lib.defaultSkills.nix
#     // jstack.lib.defaultSkills.golang
#     // jstack.lib.defaultSkills.typescript;
#
# Each group maps skill names to { src = <path>; } attrsets.
# The `all` attribute merges all groups.
#
# These reference paths relative to this file's location (../skills/<name>).
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

  golang = mkSkills [
    "golang-benchmark"
    "golang-cli"
    "golang-code-style"
    "golang-concurrency"
    "golang-context"
    "golang-continuous-integration"
    "golang-data-structures"
    "golang-database"
    "golang-dependency-injection"
    "golang-dependency-management"
    "golang-design-patterns"
    "golang-documentation"
    "golang-error-handling"
    "golang-grpc"
    "golang-linter"
    "golang-modern-syntax"
    "golang-modernize"
    "golang-naming"
    "golang-observability"
    "golang-performance"
    "golang-popular-libraries"
    "golang-project-layout"
    "golang-safety"
    "golang-samber-do"
    "golang-samber-hot"
    "golang-samber-lo"
    "golang-samber-mo"
    "golang-samber-oops"
    "golang-samber-ro"
    "golang-samber-slog"
    "golang-security"
    "golang-stay-updated"
    "golang-stretchr-testify"
    "golang-structs-interfaces"
    "golang-testing"
    "golang-troubleshooting"
  ];

  rust = mkSkills [
    "coding-guidelines"
    "domain-cli"
    "domain-cloud-native"
    "domain-embedded"
    "domain-fintech"
    "domain-iot"
    "domain-ml"
    "domain-web"
    "m01-ownership"
    "m02-resource"
    "m03-mutability"
    "m04-zero-cost"
    "m05-type-driven"
    "m06-error-handling"
    "m07-concurrency"
    "m09-domain"
    "m10-performance"
    "m11-ecosystem"
    "m12-lifecycle"
    "m13-domain-error"
    "m14-mental-model"
    "m15-anti-pattern"
    "rust-call-graph"
    "rust-code-navigator"
    "rust-deps-visualizer"
    "rust-refactor-helper"
    "rust-symbol-analyzer"
    "rust-trait-explorer"
    "unsafe-checker"
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
    "search-params"
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
    "promptfoo-evals"
    "redteam-plugin-development"
  ];

  obsidian = mkSkills [
    "defuddle"
    "json-canvas"
    "obsidian-bases"
    "obsidian-cli"
    "obsidian-markdown"
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

  productivity = mkSkills [
    "session-log"
  ];

  skill-creator = mkSkills [
    "skill-creator"
    "skill-creator-lang"
  ];

  # All skills merged into a single attrset.
  all =
    nix
    // golang
    // rust
    // python
    // typescript
    // jvm
    // emacs
    // claude-ecosystem
    // obsidian
    // gitlab
    // storage
    // productivity
    // skill-creator;
}
