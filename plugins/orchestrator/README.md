# orchestrator

Claude Code plugin implementing the orchestrator pattern: the main agent only routes, decides, and synthesizes — all file reading and code editing is delegated to model-routed sub-agents.

## Components

- `agents/code-locator.md` — haiku; grep-tier mechanical lookups (Glob/Grep/Read only)
- `agents/code-researcher.md` — opus; multi-file analysis, writes self-contained specs to `.agent/docs/sub-agent/`
- `agents/implementer.md` — sonnet; implements strictly from a spec path, runs lint/tests, never commits without explicit authorization
- `hooks/hooks.json` + `rules/orchestrator-rules.md` — SessionStart hook injecting the routing rules into every session where the plugin is enabled

## Model overrides

Defaults live in each agent's frontmatter. Override per Task call only when the routing table in `rules/orchestrator-rules.md` says so (e.g. `model: opus` for complex implementation, `model: sonnet` for narrow research).
