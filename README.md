# gt-plugins

Personal extensions for AI coding tools — one repo, three consumers.

| Plugin | Claude Code | Codex | OpenCode |
|---|---|---|---|
| [prompt-lab](plugins/prompt-lab/) | ✅ full (skills, commands, agents, hook) | ✅ skills | ✅ skills |
| [orchestrator](plugins/orchestrator/) | ✅ | — | — |

## Layout

- `plugins/` — cross-tool plugin packages. One directory per plugin; one manifest per supported
  tool side by side: `.claude-plugin/plugin.json` (Claude Code), `.codex-plugin/plugin.json` (Codex).
  Skills follow the open Agent Skills standard (`SKILL.md`) and are written once.
- `.claude-plugin/marketplace.json` — Claude Code marketplace catalog.
- `.agents/plugins/marketplace.json` — Codex marketplace catalog.
- `opencode/` — OpenCode artifacts (symlinks into `plugins/*/skills/`; OpenCode reads them live).
- `codex/` — Codex-specific artifacts (rules, subagent roles); empty for now.

## Install

**Claude Code**

```
claude plugin marketplace add gooonzick/gt-plugins
claude plugin install prompt-lab@gt-plugins
```

**Codex**

```
make install-codex        # = codex plugin marketplace add <this repo>
```

then install `prompt-lab` via `codex` → `/plugins`.

**OpenCode**

```
make install-opencode     # symlinks skills into ~/.config/opencode/skills
```

## Updating after changing a plugin

Bump `version` in BOTH manifests of the plugin (`.claude-plugin/plugin.json` and
`.codex-plugin/plugin.json` — keep them identical), commit, then:

```
claude plugin marketplace update gt-plugins && claude plugin update prompt-lab@gt-plugins
codex plugin marketplace upgrade gt-plugins
```

OpenCode needs nothing — it reads the repo live through symlinks.

## Validate

```
make validate
```
