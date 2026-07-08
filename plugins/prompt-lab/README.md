# prompt-lab

Prompt engineering lab for Claude Code: analyze, improve, create, test, adapt, audit, and catalog prompts. A companion plugin to [promptingguide.ai](https://www.promptingguide.ai) — analysis is grounded in the guide's technique catalog plus current Anthropic/OpenAI best practices.

**The differentiator:** improvements are verified by execution, not vibes. `/prompt-lab:improve` runs the original and the rewrite against generated test cases in clean-context subagents, then a blind judge scores them A/B — you get an evidence table, not promises.

## Install

From the `gt-plugins` marketplace:

```
/plugin marketplace add gooonzick/gt-plugins
/plugin install prompt-lab@gt-plugins
```

## Commands

| Command | What it does |
|---|---|
| `/prompt-lab:analyze <file\|text>` | Rubric-scored analysis: 9 dimensions, evidence quotes, concrete fixes with technique citations |
| `/prompt-lab:improve <file\|text>` | Analysis → annotated rewrite → optional A/B verification by real runs |
| `/prompt-lab:create <task>` | Interview-driven prompt builder |
| `/prompt-lab:test <file> [--vs <file2>]` | Test matrix → clean-context runs → blind judge → verdict table |
| `/prompt-lab:audit [path]` | Find prompts embedded in a codebase, inventory, batch-analyze |
| `/prompt-lab:adapt <file> --to claude\|gpt\|compress` | Port between vendors or compress without behavior change |
| `/prompt-lab:save [file]` | Save a prompt to your personal library |
| `/prompt-lab:find <query>` | Search your library |

Skills also trigger automatically — "why does this prompt keep hallucinating?" invokes the analysis skill without a command.

## Prompt library

Saved prompts live in `$PROMPT_LIBRARY_DIR` (default `~/prompt-library`) as markdown with frontmatter (name, description, tags, model, version, tested date). Your prompts stay on your machine — the library is user data, not part of the plugin.

## Hook

One advisory PostToolUse hook: when a prompt-like file is edited (`prompts/`, `*.prompt.md`, `SKILL.md`, `CLAUDE.md`, agent definitions…), Claude gets a soft reminder that analysis is available. It never blocks and never auto-runs anything.

## Limitations

- Test runs execute on Claude (via Claude Code subagents). For prompts targeting other vendors, treat run results as an approximation; the ported text from `/prompt-lab:adapt` is still vendor-idiomatic.
- Test runs cost tokens: every run plan is shown for confirmation before anything is spawned.

## Methodology

Rubric dimensions: task clarity, structure, role/context, examples quality, output format, edge-case handling, injection resistance, token efficiency, model fit. Technique citations link to [promptingguide.ai/techniques](https://www.promptingguide.ai/techniques) — this plugin curates and references the guide rather than copying it.
