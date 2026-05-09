---
name: gitlab
description: Use for GitLab work — CI/CD pipeline configuration in `.gitlab-ci.yml` (pipeline templates, downstream pipelines, Docker builds, caching strategies, CI/CD components, runner config, artifacts vs cache, pipeline inputs, duplicate pipeline traps) and the `glab` CLI for terminal-based GitLab workflows (merge requests, issues, epics, work items, comments, Quick Actions, GitLab API queries, inline review comments). Read the matching reference before editing pipelines or running glab.
---

# GitLab skill index

Pick the topic and read its reference before editing GitLab pipelines
or scripting against the GitLab API.

| Topic | When to read | Reference |
|---|---|---|
| CI/CD (.gitlab-ci.yml) | pipeline templates, components, downstream pipelines, Docker builds, caching, runner config, artifacts vs cache, pipeline inputs | `references/cicd.md` (+ `cicd/pipeline-templates.md`) |
| glab CLI | merge requests, issues, epics, work items, comments, Quick Actions, GitLab API, inline review comments | `references/glab.md` (+ `glab/work-items.md`, `glab/issue-links.md`, `glab/epics.md`, `glab/epic-comments.md`, `glab/nested-groups.md`) |

Helper scripts live under `scripts/` (sibling to `references/`):
`add-inline-comment.sh`, `batch-label-issues.sh`, `ci-debug.sh`,
`create-epic-note.sh`, `create-mr-from-issue.sh`, `epic-notes.sh`,
`mr-review-workflow.sh`, `post-inline-comment.py`, `sync-fork.sh`.
Assets (GraphQL queries) live under `assets/graphql/`.

After reading the reference, follow its guidance for the task.
