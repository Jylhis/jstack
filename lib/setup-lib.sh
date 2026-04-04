#!/usr/bin/env bash
# lib/setup-lib.sh — shared deterministic setup functions
# Sourced by: setup, devenv.nix enterShell
#
# Required env before sourcing:
#   SOURCE_JSTACK_DIR  — absolute path to the jstack repo root
#   IS_WINDOWS         — 0 or 1 (default: 0)
#   SKILL_PREFIX       — 0 (flat names) or 1 (jstack- prefix) (default: 0)

[ -n "${_SETUP_LIB_LOADED:-}" ] && return 0
_SETUP_LIB_LOADED=1

: "${SOURCE_JSTACK_DIR:?SOURCE_JSTACK_DIR must be set before sourcing setup-lib.sh}"
: "${IS_WINDOWS:=0}"
: "${SKILL_PREFIX:=0}"

# ─── Playwright validation ───────────────────────────────────────────────────

ensure_playwright_browser() {
  if [ "$IS_WINDOWS" -eq 1 ]; then
    # On Windows, Bun can't launch Chromium due to broken pipe handling
    # (oven-sh/bun#4253). Use Node.js to verify Chromium works instead.
    (
      cd "$SOURCE_JSTACK_DIR"
      node -e "const { chromium } = require('playwright'); (async () => { const b = await chromium.launch(); await b.close(); })()" 2>/dev/null
    )
  else
    (
      cd "$SOURCE_JSTACK_DIR"
      bun --eval 'import { chromium } from "playwright"; const browser = await chromium.launch(); await browser.close();'
    ) >/dev/null 2>&1
  fi
}

ensure_playwright_chromium() {
  if ! ensure_playwright_browser; then
    echo "Installing Playwright Chromium..."
    (
      cd "$SOURCE_JSTACK_DIR"
      bunx playwright install chromium
    )

    if [ "$IS_WINDOWS" -eq 1 ]; then
      # On Windows, Node.js launches Chromium (not Bun — see oven-sh/bun#4253).
      # Ensure playwright is importable by Node from the jstack directory.
      if ! command -v node >/dev/null 2>&1; then
        echo "jstack setup failed: Node.js is required on Windows (Bun cannot launch Chromium due to a pipe bug)" >&2
        echo "  Install Node.js: https://nodejs.org/" >&2
        return 1
      fi
      echo "Windows detected — verifying Node.js can load Playwright..."
      (
        cd "$SOURCE_JSTACK_DIR"
        # Bun's node_modules already has playwright; verify Node can require it
        node -e "require('playwright')" 2>/dev/null || npm install --no-save playwright
      )
    fi
  fi

  if ! ensure_playwright_browser; then
    if [ "$IS_WINDOWS" -eq 1 ]; then
      echo "jstack setup failed: Playwright Chromium could not be launched via Node.js" >&2
      echo "  This is a known issue with Bun on Windows (oven-sh/bun#4253)." >&2
      echo "  Ensure Node.js is installed and 'node -e \"require('playwright')\"' works." >&2
    else
      echo "jstack setup failed: Playwright Chromium could not be launched" >&2
    fi
    return 1
  fi
}

# ─── Binary build ────────────────────────────────────────────────────────────

# Smart rebuild: only build if sources are newer than the binary.
# Args: $1 = jstack dir, $2 = browse binary path
# Returns: 0 if build ran or was unnecessary, 1 on failure
smart_rebuild() {
  local jstack_dir="$1"
  local browse_bin="$2"
  local needs_build=0

  if [ ! -x "$browse_bin" ]; then
    needs_build=1
  elif [ -n "$(find "$jstack_dir/browse/src" -type f -newer "$browse_bin" -print -quit 2>/dev/null)" ]; then
    needs_build=1
  elif [ "$jstack_dir/package.json" -nt "$browse_bin" ]; then
    needs_build=1
  elif [ -f "$jstack_dir/bun.lock" ] && [ "$jstack_dir/bun.lock" -nt "$browse_bin" ]; then
    needs_build=1
  fi

  if [ "$needs_build" -eq 1 ]; then
    echo "Building browse binary..."
    (
      cd "$jstack_dir"
      # Skip bun install if devenv already handles it
      [ -z "${DEVENV_ROOT:-}" ] && bun install
      bun run build
    )
    # Safety net: write .version if build script didn't (e.g., git not available during build)
    if [ ! -f "$jstack_dir/browse/dist/.version" ]; then
      git -C "$jstack_dir" rev-parse HEAD > "$jstack_dir/browse/dist/.version" 2>/dev/null || true
    fi
  fi

  if [ ! -x "$browse_bin" ]; then
    echo "jstack setup failed: browse binary missing at $browse_bin" >&2
    return 1
  fi
}

# ─── Skill doc generation ────────────────────────────────────────────────────

# Generate .agents/ Codex skill docs. Always regenerate to prevent stale descriptions.
# Args: $1 = jstack dir
gen_agents_skill_docs() {
  local jstack_dir="$1"
  echo "Generating .agents/ skill docs..."
  (
    cd "$jstack_dir"
    bun install --frozen-lockfile 2>/dev/null || bun install
    bun run gen:skill-docs --host codex
  )
}

# ─── Global state directory ──────────────────────────────────────────────────

ensure_jstack_dirs() {
  mkdir -p "$HOME/.jstack/projects"
}

# ─── Claude skill symlinks ───────────────────────────────────────────────────

# Link Claude skill subdirectories into a skills parent directory.
# When SKILL_PREFIX=1, symlinks are prefixed with "jstack-" to avoid
# namespace pollution (e.g., jstack-review instead of review).
# Args: $1 = jstack dir, $2 = skills dir
link_claude_skill_dirs() {
  local jstack_dir="$1"
  local skills_dir="$2"
  local linked=()
  for skill_dir in "$jstack_dir"/*/; do
    if [ -f "$skill_dir/SKILL.md" ]; then
      skill_name="$(basename "$skill_dir")"
      # Skip node_modules
      [ "$skill_name" = "node_modules" ] && continue
      # Apply jstack- prefix unless --no-prefix or already prefixed
      if [ "$SKILL_PREFIX" -eq 1 ]; then
        case "$skill_name" in
          jstack-*) link_name="$skill_name" ;;
          *)        link_name="jstack-$skill_name" ;;
        esac
      else
        link_name="$skill_name"
      fi
      target="$skills_dir/$link_name"
      # Create or update symlink; skip if a real file/directory exists
      if [ -L "$target" ] || [ ! -e "$target" ]; then
        ln -snf "jstack/$skill_name" "$target"
        linked+=("$link_name")
      fi
    fi
  done
  if [ ${#linked[@]} -gt 0 ]; then
    echo "  linked skills: ${linked[*]}"
  fi
}

# Remove old unprefixed Claude skill symlinks.
# Migration: when switching from flat names to jstack- prefixed names,
# clean up stale symlinks that point into the jstack directory.
# Args: $1 = jstack dir, $2 = skills dir
cleanup_old_claude_symlinks() {
  local jstack_dir="$1"
  local skills_dir="$2"
  local removed=()
  for skill_dir in "$jstack_dir"/*/; do
    if [ -f "$skill_dir/SKILL.md" ]; then
      skill_name="$(basename "$skill_dir")"
      [ "$skill_name" = "node_modules" ] && continue
      # Skip already-prefixed dirs (jstack-upgrade) — no old symlink to clean
      case "$skill_name" in jstack-*) continue ;; esac
      old_target="$skills_dir/$skill_name"
      # Only remove if it's a symlink pointing into jstack/
      if [ -L "$old_target" ]; then
        link_dest="$(readlink "$old_target" 2>/dev/null || true)"
        case "$link_dest" in
          jstack/*|*/jstack/*)
            rm -f "$old_target"
            removed+=("$skill_name")
            ;;
        esac
      fi
    fi
  done
  if [ ${#removed[@]} -gt 0 ]; then
    echo "  cleaned up old symlinks: ${removed[*]}"
  fi
}

# Remove old prefixed Claude skill symlinks.
# Reverse migration: when switching from jstack- prefixed names to flat names,
# clean up stale jstack-* symlinks that point into the jstack directory.
# Args: $1 = jstack dir, $2 = skills dir
cleanup_prefixed_claude_symlinks() {
  local jstack_dir="$1"
  local skills_dir="$2"
  local removed=()
  for skill_dir in "$jstack_dir"/*/; do
    if [ -f "$skill_dir/SKILL.md" ]; then
      skill_name="$(basename "$skill_dir")"
      [ "$skill_name" = "node_modules" ] && continue
      # Only clean up prefixed symlinks for dirs that AREN'T already prefixed
      # (e.g., remove jstack-qa but NOT jstack-upgrade which is the real dir name)
      case "$skill_name" in jstack-*) continue ;; esac
      prefixed_target="$skills_dir/jstack-$skill_name"
      # Only remove if it's a symlink pointing into jstack/
      if [ -L "$prefixed_target" ]; then
        link_dest="$(readlink "$prefixed_target" 2>/dev/null || true)"
        case "$link_dest" in
          jstack/*|*/jstack/*)
            rm -f "$prefixed_target"
            removed+=("jstack-$skill_name")
            ;;
        esac
      fi
    fi
  done
  if [ ${#removed[@]} -gt 0 ]; then
    echo "  cleaned up prefixed symlinks: ${removed[*]}"
  fi
}

# ─── Codex skill symlinks ────────────────────────────────────────────────────

# Link generated Codex skills into a skills parent directory.
# Installs from .agents/skills/jstack-* (the generated Codex-format skills)
# instead of source dirs (which have Claude paths).
# Args: $1 = jstack dir, $2 = skills dir
link_codex_skill_dirs() {
  local jstack_dir="$1"
  local skills_dir="$2"
  local agents_dir="$jstack_dir/.agents/skills"
  local linked=()

  if [ ! -d "$agents_dir" ]; then
    echo "  Generating .agents/ skill docs..."
    ( cd "$jstack_dir" && bun run gen:skill-docs --host codex )
  fi

  if [ ! -d "$agents_dir" ]; then
    echo "  warning: .agents/skills/ generation failed — run 'bun run gen:skill-docs --host codex' manually" >&2
    return 1
  fi

  for skill_dir in "$agents_dir"/jstack*/; do
    if [ -f "$skill_dir/SKILL.md" ]; then
      skill_name="$(basename "$skill_dir")"
      # Skip the sidecar directory — it contains runtime asset symlinks (bin/,
      # browse/), not a skill. Linking it would overwrite the root jstack
      # symlink that Step 5 already pointed at the repo root.
      [ "$skill_name" = "jstack" ] && continue
      target="$skills_dir/$skill_name"
      # Create or update symlink
      if [ -L "$target" ] || [ ! -e "$target" ]; then
        ln -snf "$skill_dir" "$target"
        linked+=("$skill_name")
      fi
    fi
  done
  if [ ${#linked[@]} -gt 0 ]; then
    echo "  linked skills: ${linked[*]}"
  fi
}

# ─── Agents sidecar ──────────────────────────────────────────────────────────

# Create .agents/skills/jstack/ sidecar symlinks.
# Codex/Gemini/Cursor read skills from .agents/skills/. We link runtime
# assets (bin/, browse/dist/, review/, qa/, etc.) so skill templates can
# resolve paths like $SKILL_ROOT/review/design-checklist.md.
# Args: $1 = repo root
create_agents_sidecar() {
  local repo_root="$1"
  local agents_jstack="$repo_root/.agents/skills/jstack"
  mkdir -p "$agents_jstack"

  # Sidecar directories that skills reference at runtime
  for asset in bin browse review qa; do
    local src="$SOURCE_JSTACK_DIR/$asset"
    local dst="$agents_jstack/$asset"
    if [ -d "$src" ] || [ -f "$src" ]; then
      if [ -L "$dst" ] || [ ! -e "$dst" ]; then
        ln -snf "$src" "$dst"
      fi
    fi
  done

  # Sidecar files that skills reference at runtime
  for file in ETHOS.md; do
    local src="$SOURCE_JSTACK_DIR/$file"
    local dst="$agents_jstack/$file"
    if [ -f "$src" ]; then
      if [ -L "$dst" ] || [ ! -e "$dst" ]; then
        ln -snf "$src" "$dst"
      fi
    fi
  done
}

# ─── Codex runtime root ──────────────────────────────────────────────────────

# Create a minimal ~/.codex/skills/jstack runtime root.
# Codex scans ~/.codex/skills recursively. Exposing the whole repo here causes
# duplicate skills because source SKILL.md files and generated Codex skills are
# both discoverable. Keep this directory limited to runtime assets + root skill.
# Args: $1 = jstack dir, $2 = codex jstack dir
create_codex_runtime_root() {
  local jstack_dir="$1"
  local codex_jstack="$2"
  local agents_dir="$jstack_dir/.agents/skills"

  if [ -L "$codex_jstack" ]; then
    rm -f "$codex_jstack"
  elif [ -d "$codex_jstack" ] && [ "$codex_jstack" != "$jstack_dir" ]; then
    # Old direct installs left a real directory here with stale source skills.
    # Remove it so we start fresh with only the minimal runtime assets.
    rm -rf "$codex_jstack"
  fi

  mkdir -p "$codex_jstack" "$codex_jstack/browse" "$codex_jstack/jstack-upgrade" "$codex_jstack/review"

  if [ -f "$agents_dir/jstack/SKILL.md" ]; then
    ln -snf "$agents_dir/jstack/SKILL.md" "$codex_jstack/SKILL.md"
  fi
  if [ -d "$jstack_dir/bin" ]; then
    ln -snf "$jstack_dir/bin" "$codex_jstack/bin"
  fi
  if [ -d "$jstack_dir/browse/dist" ]; then
    ln -snf "$jstack_dir/browse/dist" "$codex_jstack/browse/dist"
  fi
  if [ -d "$jstack_dir/browse/bin" ]; then
    ln -snf "$jstack_dir/browse/bin" "$codex_jstack/browse/bin"
  fi
  if [ -f "$agents_dir/jstack-upgrade/SKILL.md" ]; then
    ln -snf "$agents_dir/jstack-upgrade/SKILL.md" "$codex_jstack/jstack-upgrade/SKILL.md"
  fi
  # Review runtime assets (individual files, NOT the whole review/ dir which has SKILL.md)
  for f in checklist.md design-checklist.md greptile-triage.md TODOS-format.md; do
    if [ -f "$jstack_dir/review/$f" ]; then
      ln -snf "$jstack_dir/review/$f" "$codex_jstack/review/$f"
    fi
  done
  # ETHOS.md — referenced by "Search Before Building" in all skill preambles
  if [ -f "$jstack_dir/ETHOS.md" ]; then
    ln -snf "$jstack_dir/ETHOS.md" "$codex_jstack/ETHOS.md"
  fi
}
