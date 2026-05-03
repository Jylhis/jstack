# Canonical per-tool capability matrix used by modules and generators.
# Pure data + lightweight validation helpers.
{ lib, pkgs ? null }:
let
  matrix = {
    "claude-code" = {
      level = "user";
      paths = {
        configDir = ".claude";
        skills = ".claude/skills";
        instructions = ".claude/CLAUDE.md";
        agents = ".claude/agents";
        commands = ".claude/commands";
      };
      capabilities = {
        mcp = { support = "standalone-json"; file = ".mcp.json"; };
        lsp = { support = "standalone-json"; file = ".lsp.json"; };
        manifest = { support = "claude-plugin"; file = ".claude-plugin/plugin.json"; };
        hooks = true;
        permissions = true;
        commands = true;
        agents = true;
      };
      caveats = [ "Home Manager can delegate settings to programs.claude-code." ];
    };

    codex = {
      level = "user";
      paths = {
        configDir = ".codex";
        skillsPrimary = ".codex/skills";
        skillsAgents = ".agents/skills";
        instructions = ".codex/AGENTS.md";
      };
      capabilities = {
        mcp = { support = "embedded-toml"; file = ".codex/config.toml"; key = "mcp_servers"; };
        lsp = { support = "none"; file = null; };
        manifest = { support = "none"; file = null; };
        hooks = false;
        permissions = false;
        commands = false;
        agents = false;
      };
      caveats = [ "Skills path is selectable: .codex/skills or .agents/skills." ];
    };

    gemini = {
      level = "user";
      paths = {
        configDir = ".gemini";
        skills = ".gemini/skills";
        instructions = ".gemini/GEMINI.md";
      };
      capabilities = {
        mcp = { support = "embedded-json"; file = ".gemini/settings.json"; key = "mcpServers"; };
        lsp = { support = "none"; file = null; };
        manifest = { support = "gemini-extension"; file = "gemini-extension.json"; };
        hooks = false;
        permissions = false;
        commands = false;
        agents = false;
      };
      caveats = [ ];
    };
  };

  knownCapabilityKeys = [ "mcp" "lsp" "manifest" "hooks" "permissions" "commands" "agents" ];

  validateMatrix =
    m:
    let
      perToolChecks = lib.mapAttrsToList (
        tool: spec:
        let
          capabilityKeys = builtins.attrNames (spec.capabilities or { });
          unknown = lib.filter (k: !(builtins.elem k knownCapabilityKeys)) capabilityKeys;
          mcp = spec.capabilities.mcp or { support = "none"; file = null; };
          lsp = spec.capabilities.lsp or { support = "none"; file = null; };
          manifest = spec.capabilities.manifest or { support = "none"; file = null; };
        in
        [
          {
            assertion = unknown == [ ];
            message = "programs.jstack compatibility-matrix: ${tool} has unknown capability keys: ${lib.concatStringsSep ", " unknown}";
          }
          {
            assertion = (mcp.support == "none") == (mcp.file == null);
            message = "programs.jstack compatibility-matrix: ${tool} mcp.support='none' must have file=null (and vice versa).";
          }
          {
            assertion = (lsp.support == "none") == (lsp.file == null);
            message = "programs.jstack compatibility-matrix: ${tool} lsp.support='none' must have file=null (and vice versa).";
          }
          {
            assertion = (manifest.support == "none") == (manifest.file == null);
            message = "programs.jstack compatibility-matrix: ${tool} manifest.support='none' must have file=null (and vice versa).";
          }
        ]
      ) m;
    in
    lib.flatten perToolChecks;

  exportJson =
    if pkgs == null then
      null
    else
      pkgs.writeText "jstack-compatibility-matrix.json" (builtins.toJSON matrix);
in
{
  inherit matrix knownCapabilityKeys validateMatrix exportJson;
}
