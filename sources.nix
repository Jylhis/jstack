# Third-party skill source configuration.
#
# Each key must match a pin name in npins/sources.json.
# Add pins with: npins add github <owner> <repo>
#
# Example:
#   1. npins add github anthropics skills
#   2. Add entry below:
#      anthropic-skills = {
#        namespace = "anthropic";
#        skillsRoot = "skills";
#        maxDepth = 4;
#      };
#   3. Skills are auto-discovered and available for selection.
{
  promptfoo = {
    namespace = "promptfoo";
    skillsRoot = ".claude/skills";
  };
}
