{ config, lib, ... }:

let
  cfg = config.programs.jstack;
  runtimePkg = import (/. + cfg.repoPath + "/runtime");
  mkLink = path: config.lib.file.mkOutOfStoreSymlink (cfg.repoPath + "/" + path);

  pluginsDir = /. + cfg.repoPath + "/plugins";
  pluginBundles = lib.pipe (builtins.readDir pluginsDir) [
    (lib.filterAttrs (_: type: type == "directory"))
    (lib.filterAttrs (name: _: builtins.pathExists (pluginsDir + "/${name}/plugin.nix")))
    (lib.mapAttrsToList (name: _: pluginsDir + "/${name}"))
  ];

  # Discovery library
  discoverSkills = import (/. + cfg.repoPath + "/lib/discover.nix");

  # Discover local plugin skills
  localPluginNames = lib.pipe (builtins.readDir pluginsDir) [
    (lib.filterAttrs (_: type: type == "directory"))
    (lib.filterAttrs (name: _: builtins.pathExists (pluginsDir + "/${name}/plugin.nix")))
    builtins.attrNames
  ];

  localCatalogs = map (
    name:
    discoverSkills {
      path = pluginsDir + "/${name}/skills";
      namespace = name;
    }
  ) localPluginNames;

  localCatalog = builtins.foldl' (a: b: a // b) { } localCatalogs;

  # Discover third-party skills from npins
  thirdPartySources = import (/. + cfg.repoPath + "/sources.nix");
  npins = import (/. + cfg.repoPath + "/npins");
  thirdPartyCatalogs = lib.mapAttrsToList (
    pinName: opts:
    discoverSkills {
      path = npins.${pinName} + "/${opts.skillsRoot or "."}";
      namespace = opts.namespace;
      maxDepth = opts.maxDepth or 5;
    }
  ) thirdPartySources;

  thirdPartyCatalog =
    if cfg.thirdParty.enable then builtins.foldl' (a: b: a // b) { } thirdPartyCatalogs else { };

  fullCatalog = localCatalog // thirdPartyCatalog;

  catalogInfo = {
    totalSkills = builtins.length (builtins.attrNames fullCatalog);
    localSkills = builtins.length (builtins.attrNames localCatalog);
    thirdPartySkills = builtins.length (builtins.attrNames thirdPartyCatalog);
  };
in
{
  options.programs.jstack = {
    enable = lib.mkEnableOption "jstack multi-agent AI configuration";

    repoPath = lib.mkOption {
      type = lib.types.str;
      description = "Absolute path to the jstack repository checkout.";
      example = "/home/user/Developer/jstack";
    };

    targets = {
      claude = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Deploy skills and plugins to Claude Code (~/.claude/).";
        };
      };
      codex = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Deploy skills to Codex CLI (~/.codex/).";
        };
      };
      gemini = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Deploy skills to Gemini CLI (~/.gemini/).";
        };
      };
    };

    thirdParty = {
      enable = lib.mkEnableOption "third-party skill sources via npins";
      selectedSkills = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = ''
          List of skill IDs to enable from third-party sources.
          Use "namespace:skill-name" format (e.g. "anthropic:frontend-design").
          Leave empty to enable all discovered third-party skills.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # ── Claude Code target (default, backwards-compat) ──
      (lib.mkIf cfg.targets.claude.enable {
        programs.claude-code.settings = import ((/. + cfg.repoPath) + "/settings.nix");
        programs.claude-code.memory.source = mkLink "CLAUDE.md";
        programs.claude-code.plugins = pluginBundles;

        home.file = {
          ".claude/skills".source = mkLink "skills";
          ".claude/agents".source = mkLink "agents";
          ".claude/commands".source = mkLink "commands";
          ".claude/hooks".source = mkLink "hooks";
          ".claude/plugins".source = mkLink "plugins";
        };
      })

      # ── Codex target ──
      (lib.mkIf cfg.targets.codex.enable {
        home.file = {
          ".codex/skills".source = mkLink "skills";
        };
      })

      # ── Gemini CLI target ──
      (lib.mkIf cfg.targets.gemini.enable {
        home.file = {
          ".gemini/skills".source = mkLink "skills";
        };
      })

      # ── Shared (runtime, env) ──
      {
        home.packages = [ runtimePkg ];
        home.sessionVariables = {
          JSTACK_RUNTIME = "${runtimePkg}";
        };
      }
    ]
  );
}
