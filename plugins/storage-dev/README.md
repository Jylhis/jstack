# storage-dev

Copy-on-write filesystem intelligence for jstack: 3 skills covering
the three filesystems that matter for a multi-platform dev setup —
APFS on macOS, Btrfs on Linux/NixOS workstations, and ZFS on NixOS
homelab servers. Each skill captures the reflink semantics, dataset
or subvolume layouts, tuning knobs, and snapshot workflows for its
filesystem.

## Contents

- `.claude-plugin/plugin.json` — plugin manifest (auto-generated from `plugin.nix`)
- `skills/` — 3 skill directories with `SKILL.md`

This plugin is part of [jstack](../../) and is installed into
`~/.claude/plugins/storage-dev/` automatically by the jstack installer.
There is no separate install step.

## Skills

`apfs`, `btrfs`, `zfs`

Each skill loads automatically when the conversation mentions its
filesystem, relevant tooling (`cp -c`, `zpool`, `btrfs`, `sanoid`,
`bees`, `reflink`, `clonefile`, …), or integration topics (Nix-on-macOS
synthetic mount, NixOS impermanence pattern, Hetzner ZFS tuning).

## No MCP, LSP, or extra packages

The storage skills are pure knowledge — they do not ship an MCP
server, LSP, or package set. Tool detection blocks in each skill
check for `diskutil`/`mdutil` (apfs), `btrfs`/`compsize` (btrfs),
and `zfs`/`zpool`/`arc_summary` (zfs) at the user's shell and only
report what is missing.
