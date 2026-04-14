# Instruction file assembly — combines shared and per-tool instructions.
#
# Each tool has its own instruction file (CLAUDE.md, AGENTS.md, GEMINI.md, etc.).
# Content is: shared instructions (from programs.jstack.instructions) followed by
# tool-specific additions (from programs.jstack.tools.<name>.extraInstructions).
#
# Pure function, no pkgs needed.
{ lib }:
{
  # mkInstructionFile :: { shared : string, extra : string } -> string
  #
  # Concatenates non-empty sections with double newlines between them.
  # Returns empty string if both inputs are empty.
  mkInstructionFile =
    {
      shared ? "",
      extra ? "",
    }:
    lib.concatStringsSep "\n\n" (
      lib.filter (s: s != "") [
        shared
        extra
      ]
    );
}
