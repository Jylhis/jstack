{ config, lib, ... }:

let
  cfg = config.programs.jstack;
  runtimePkg = import (/. + cfg.repoPath + "/runtime");
  mkLink = path:
    config.lib.file.mkOutOfStoreSymlink (cfg.repoPath + "/" + path);
in
{
  options.programs.jstack = {
    enable = lib.mkEnableOption "jstack Claude Code configuration";

    repoPath = lib.mkOption {
      type = lib.types.str;
      description = "Absolute path to the jstack repository checkout.";
      example = "/home/user/Developer/jstack";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file = {
      ".claude/settings.json".source = mkLink "settings.json";
      ".claude/CLAUDE.md".source = mkLink "CLAUDE.md";
      ".claude/skills".source = mkLink "skills";
      ".claude/agents".source = mkLink "agents";
      ".claude/commands".source = mkLink "commands";
      ".claude/hooks".source = mkLink "hooks";
      ".claude/plugins".source = mkLink "plugins";
    };

    home.packages = [ runtimePkg ];

    home.sessionVariables = {
      JSTACK_RUNTIME = "${runtimePkg}";
    };
  };
}
