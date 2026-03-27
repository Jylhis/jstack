export type Host = 'claude' | 'codex';

export interface HostPaths {
  skillRoot: string;
  localSkillRoot: string;
  binDir: string;
  browseDir: string;
}

export const HOST_PATHS: Record<Host, HostPaths> = {
  claude: {
    skillRoot: '~/.claude/skills/jstack',
    localSkillRoot: '.claude/skills/jstack',
    binDir: '~/.claude/skills/jstack/bin',
    browseDir: '~/.claude/skills/jstack/browse/dist',
  },
  codex: {
    skillRoot: '$JSTACK_ROOT',
    localSkillRoot: '.agents/skills/jstack',
    binDir: '$JSTACK_BIN',
    browseDir: '$JSTACK_BROWSE',
  },
};

export interface TemplateContext {
  skillName: string;
  tmplPath: string;
  benefitsFrom?: string[];
  host: Host;
  paths: HostPaths;
  preambleTier?: number;  // 1-4, controls which preamble sections are included
}
