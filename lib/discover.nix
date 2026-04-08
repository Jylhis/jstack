# Recursive SKILL.md discovery.
#
# Scans a directory tree for subdirectories containing SKILL.md files and
# returns an attribute set of discovered skills keyed by their qualified ID.
#
# Usage:
#   discoverSkills { path = ./plugins/nix-dev/skills; namespace = "nix-dev"; }
#   => { "nix-dev:flakes" = { id = "nix-dev:flakes"; name = "flakes"; ... }; ... }

{
  path,
  namespace,
  maxDepth ? 5,
}:
let
  # Walk a directory recursively up to depth limit, collecting skills.
  walk =
    dir: depth: prefix:
    let
      entries = builtins.readDir dir;
      names = builtins.attrNames entries;
    in
    builtins.foldl' (
      acc: name:
      let
        entryType = entries.${name};
        entryPath = dir + "/${name}";
        skillFile = entryPath + "/SKILL.md";
        relativePath = if prefix == "" then name else "${prefix}/${name}";
        id = "${namespace}:${name}";
      in
      if entryType != "directory" then
        acc
      else if builtins.pathExists skillFile then
        # Found a skill — record it, do not recurse further into this dir
        let
          existing = acc ? ${id};
        in
        if existing then
          builtins.abort "jstack: duplicate skill ID '${id}' discovered at '${toString entryPath}' (namespace '${namespace}')"
        else
          acc
          // {
            ${id} = {
              inherit
                id
                name
                namespace
                relativePath
                ;
              path = entryPath;
            };
          }
      else if depth > 0 then
        # No SKILL.md here — recurse deeper
        acc // (walk entryPath (depth - 1) relativePath)
      else
        acc
    ) { } names;
in
if builtins.pathExists path then walk path maxDepth "" else { }
