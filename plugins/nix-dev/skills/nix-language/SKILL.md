---
name: nix-language
description: "Use when working with Nix expression language fundamentals including syntax, expressions, functions, builtins, let-in bindings, with expressions, inherit, rec, attrsets, attribute sets, string interpolation, derivations, import, fetchurl, fixed-point patterns, nixpkgs lib functions, lambdas, operators, or lazy evaluation."
user-invocable: false
---

# Nix Language

## Core Data Types

| Type | Example | Notes |
|------|---------|-------|
| String | `"hello ${name}"` | Interpolation with `${}`, multiline with `''` |
| Integer | `42` | |
| Float | `1.0`, `3.14` | Rarely used in nixpkgs |
| Boolean | `true` / `false` | |
| Null | `null` | |
| Path | `./foo.nix`, `<nixpkgs>` | Paths are resolved relative to the file |
| List | `[ 1 2 3 ]` | Space-separated, heterogeneous |
| Attribute set | `{ a = 1; b = 2; }` | Key-value map, semicolons required |
| Function | `x: x + 1` | Single-argument, curried |

## Functions

```nix
# Curried
add = a: b: a + b;

# Attrset pattern (most common in nixpkgs)
mkDerivation = { pname, version, src, ... }: { /* ... */ };

# With defaults
mkDerivation = { pname, version, src, buildInputs ? [], ... }: { /* ... */ };
```

The `@` pattern captures the full attrset: `{ pname, ... } @ args:`.

## Key Constructs

### let-in

```nix
let
  x = 1;
  y = x + 1;
in x + y
```

### with

```nix
with pkgs; [ git curl wget ]
# equivalent to: [ pkgs.git pkgs.curl pkgs.wget ]
```

### inherit

```nix
{ inherit src version; }
# equivalent to: { src = src; version = version; }

{ inherit (pkgs) git curl; }
# equivalent to: { git = pkgs.git; curl = pkgs.curl; }
```

### rec (recursive attrsets)

```nix
rec {
  x = 1;
  y = x + 1;  # works because of rec
}
```

### Conditionals

```nix
if condition then valueA else valueB
```

## String Patterns

```nix
# Multiline (strips leading whitespace)
''
  line 1
  line 2
''

# Escape interpolation in multiline
''
  literal ''${not-interpolated}
''

# String interpolation
"Hello ${name}, you have ${toString count} items"
```

## Derivations

```nix
stdenv.mkDerivation {
  pname = "hello";
  version = "1.0";
  src = ./src;
  buildInputs = [ pkg-config openssl ];
  buildPhase = ''
    make
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp hello $out/bin/
  '';
}
```

Key concept: `$out` is the Nix store path where the build output goes.

## Important Builtins

| Builtin | Purpose |
|---------|---------|
| `builtins.map` | Transform list elements |
| `builtins.filter` | Filter list by predicate |
| `builtins.attrNames` | Get attrset keys as list |
| `builtins.attrValues` | Get attrset values as list |
| `builtins.hasAttr` | Check if key exists |
| `builtins.elem` | Check if element in list |
| `builtins.toString` | Convert to string |
| `builtins.toJSON` | Serialize to JSON |
| `builtins.fromJSON` | Parse JSON string |
| `builtins.readFile` | Read file contents at eval time |
| `builtins.fetchurl` | Fetch URL at eval time |
| `builtins.trace` | Debug print during evaluation |
| `import` | Load and evaluate a `.nix` file |

## nixpkgs `lib` Essentials

```nix
lib.mkIf condition value        # Conditional config (NixOS modules)
lib.mkMerge [ a b ]             # Merge multiple configs
lib.optionals bool list         # Conditional list items
lib.optional bool value         # Conditional single item as list
lib.filterAttrs pred set        # Filter attrset
lib.mapAttrs f set              # Transform attrset values
lib.genAttrs names f            # Generate attrset from names
lib.concatMapStringsSep sep f l # Map + join strings
lib.recursiveUpdate a b         # Deep merge attrsets
```

## Laziness

- Infinite data structures (nixpkgs is a giant attrset, only needed packages are evaluated)
- Self-referencing configurations (NixOS modules reference each other)
- `throw` in unused branches doesn't error

## Anti-Patterns

- **Avoid `rec`** when `let-in` works — `rec` makes the whole attrset depend on itself
- **Avoid `with pkgs;` in large scopes** — makes it unclear where names come from, doesn't shadow let-bindings
- **Don't use `builtins.toPath`** — it's deprecated
- **Don't read secrets at eval time** — `builtins.readFile` embeds content in the store (world-readable)
