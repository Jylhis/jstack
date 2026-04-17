{
  pkgs ? import (import ../_sources.nix).nixpkgs { },
}:
let
  servers = import ../lib/servers.nix { inherit pkgs; };
in
pkgs.buildEnv {
  name = "claude-runtime";
  paths = servers.packages;
}
