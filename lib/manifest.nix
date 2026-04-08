# Manifest generators — produce agent-specific config files from plugin.nix attrsets.
{ pkgs }:
let
  hasAttr = name: set: set ? ${name} && set.${name} != { };
in
{
  # Claude Code .claude-plugin/plugin.json
  mkClaudeManifest =
    pluginDef:
    builtins.toJSON (
      {
        inherit (pluginDef) name description;
        author = pluginDef.author or { };
      }
      // (if pluginDef ? version then { inherit (pluginDef) version; } else { })
    );

  # Gemini CLI gemini-extension.json
  mkGeminiManifest =
    pluginDef:
    builtins.toJSON (
      {
        inherit (pluginDef) name description;
      }
      // (if pluginDef ? version then { inherit (pluginDef) version; } else { })
      // (if hasAttr "mcpServers" pluginDef then { inherit (pluginDef) mcpServers; } else { })
    );

  # .mcp.json — returns JSON string or null
  mkMcpConfig =
    pluginDef:
    if hasAttr "mcpServers" pluginDef then
      builtins.toJSON { inherit (pluginDef) mcpServers; }
    else
      null;

  # .lsp.json — returns JSON string or null
  mkLspConfig =
    pluginDef: if hasAttr "lspServers" pluginDef then builtins.toJSON pluginDef.lspServers else null;

  # Build a complete plugin directory with generated manifests as a derivation.
  # Returns a store path containing .claude-plugin/plugin.json, .mcp.json, .lsp.json as needed.
  mkPluginManifests =
    {
      pluginDef,
      target ? "claude",
    }:
    let
      targets = import ./targets.nix;
      t = targets.${target};
      self = pkgs.lib.getAttrs [ "mkClaudeManifest" "mkGeminiManifest" "mkMcpConfig" "mkLspConfig" ] (
        import ./manifest.nix { inherit pkgs; }
      );
    in
    pkgs.runCommand "jstack-manifests-${pluginDef.name}" { } (
      ''
        mkdir -p $out
      ''
      + (
        if target == "claude" then
          ''
            mkdir -p $out/.claude-plugin
            cat > $out/.claude-plugin/plugin.json <<'EOF'
            ${self.mkClaudeManifest pluginDef}
            EOF
          ''
        else if target == "gemini" then
          ''
            cat > $out/gemini-extension.json <<'EOF'
            ${self.mkGeminiManifest pluginDef}
            EOF
          ''
        else
          ""
      )
      + (
        let
          mcp = self.mkMcpConfig pluginDef;
        in
        if mcp != null && t.mcpConfigFile != null then
          ''
            cat > $out/${t.mcpConfigFile} <<'EOF'
            ${mcp}
            EOF
          ''
        else
          ""
      )
      + (
        let
          lsp = self.mkLspConfig pluginDef;
        in
        if lsp != null && t.lspConfigFile != null then
          ''
            cat > $out/${t.lspConfigFile} <<'EOF'
            ${lsp}
            EOF
          ''
        else
          ""
      )
    );
}
