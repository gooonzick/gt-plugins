# gt-plugins — Multi-tool plugin repository (Design)

**Date:** 2026-07-08
**Status:** Approved design, pending implementation plan
**Scope:** Reorganize this repo to host extensions for Claude Code, OpenAI Codex CLI, and OpenCode — plus a first working port: prompt-lab skills available in Codex and OpenCode.

## 1. Overview

One personal monorepo (`gooonzick/gt-plugins`) serving three AI coding tools. The organizing principle is **dual-manifest plugin packages**: a plugin lives in ONE directory under `plugins/` and declares support for each tool via that tool's own manifest file side by side (`.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`). Tool-specific artifacts that don't fit the package model (OpenCode JS plugins/commands, Codex rules) live in per-tool top-level dirs.

The portable unit across all three tools is the **Agent Skill** (`SKILL.md` with `name` + `description` frontmatter) — an open standard supported natively by Claude Code, Codex, and OpenCode.

### Decisions log (2026-07-08 brainstorming)

| Decision | Choice |
|---|---|
| Content model | Both cross-tool packages (shared core) and tool-specific extensions |
| Scope now | Reorganization + first port: prompt-lab skills → Codex and OpenCode |
| Layout | Dual-manifest packages in `plugins/`, per-tool dirs for the rest |
| Prerequisite | `feature/prompt-lab` merged to `main` first (done 2026-07-08) |
| Local repo path | Keep `~/Development/claude-plugins` (Claude marketplace registration points at it; no rename) |
| OpenCode | Not installed yet — structure + install tooling prepared, live verification deferred |

## 2. Verified platform facts (research, 2026-07-08)

**Claude Code** ([plugin-marketplaces docs](https://code.claude.com/docs/en/plugin-marketplaces.md)):
- Marketplace `source` accepts nested relative paths (`"./plugins/prompt-lab"`); resolved from marketplace root; `../` forbidden.
- Installed plugins are cached by version. Moving a plugin's path requires a **version bump** (in plugin.json or the marketplace entry) for `/plugin update` to fetch fresh content; no reinstall needed.

**Codex CLI** (v0.142.4 installed; [plugins](https://developers.openai.com/codex/plugins/build), [skills](https://developers.openai.com/codex/skills), [hooks](https://developers.openai.com/codex/hooks)):
- Native plugin system: manifest `.codex-plugin/plugin.json` (`name` = identifier and component namespace, `version`, `description`, pointers like `skills: "./skills/"`). Plugin components (`skills/`, `hooks/`, `.mcp.json`) live at plugin root.
- Marketplace catalogs: `$REPO_ROOT/.agents/plugins/marketplace.json` (repo), `~/.agents/plugins/marketplace.json` (personal), and **legacy-compatible `.claude-plugin/marketplace.json`**. Registration: `codex plugin marketplace add <owner/repo | git URL | local dir>`; installed plugins cached under `~/.codex/plugins/cache/…` (local sources use version `"local"`).
- Skills = open Agent Skills standard, same `SKILL.md`; user-scope dir is `~/.agents/skills` (NOT `~/.codex/skills`). Custom prompts are deprecated in favor of skills.
- Hooks exist (Claude-like events; sets `CLAUDE_PLUGIN_ROOT` for compat) but PostToolUse output supports `systemMessage`/`continue` — **not** `additionalContext`. Our hook would be a no-op there.

**OpenCode** ([docs](https://opencode.ai/docs); repo moved to `github.com/anomalyco/opencode`):
- No marketplace. Artifacts are plain directories, project (`.opencode/…`) or global (`~/.config/opencode/…`): `plugins/` (JS/TS hook modules), `agents/`, `commands/` (markdown, supports `$ARGUMENTS`), `skills/`, `tools/`, `themes/`.
- Skills: Claude-compatible `SKILL.md` read natively from `…/skills/<name>/SKILL.md` (also reads `.claude/skills` and `.agents/skills` paths). Frontmatter: `name` (must equal directory name, kebab regex), `description` required; unknown fields ignored.
- Reads files **live** (no install cache) → symlinks are safe.
- `OPENCODE_CONFIG_DIR` env var can point at any directory searched like `.opencode` (additive) — alternative install mechanism.

## 3. Target layout

```
gt-plugins/                              (~/Development/claude-plugins)
  .claude-plugin/
    marketplace.json                     # Claude Code: sources → ./plugins/*
  .agents/
    plugins/
      marketplace.json                   # Codex-native catalog: sources → ./plugins/*
  plugins/                               # cross-tool plugin packages
    orchestrator/                        # Claude-only today (one manifest)
      .claude-plugin/plugin.json         # version 1.0.0 → 1.0.1 (path move)
      agents/ hooks/ rules/ README.md
    prompt-lab/
      .claude-plugin/plugin.json         # version 0.1.0 → 0.1.1 (path move)
      .codex-plugin/plugin.json          # NEW: name, version, description, skills: "./skills/"
      skills/ commands/ agents/ hooks/ examples/ README.md
  opencode/                              # OpenCode artifacts (live-read by symlink install)
    skills/
      prompt-analysis   -> ../../plugins/prompt-lab/skills/prompt-analysis    (symlink)
      prompt-creation   -> ../../plugins/prompt-lab/skills/prompt-creation    (symlink)
      prompt-testing    -> ../../plugins/prompt-lab/skills/prompt-testing     (symlink)
      prompt-adaptation -> ../../plugins/prompt-lab/skills/prompt-adaptation  (symlink)
      prompt-library    -> ../../plugins/prompt-lab/skills/prompt-library     (symlink)
    README.md                            # what lives here, how install works
  codex/                                 # Codex-specific artifacts (rules, agent .toml) — empty for now
    README.md                            # placeholder explaining purpose
  docs/superpowers/{specs,plans}/        # unchanged
  Makefile                               # validate, install-opencode, install-codex
  README.md                              # rewritten: multi-tool positioning + plugin×tool matrix
```

Notes:
- `prompt-lab` testing agents/commands/hook remain Claude-only components; other tools consume only its `skills/` for now.
- The prompt-lab **skills mention Claude-specific companions** (e.g. "offer `/prompt-lab:test`", "spawn `prompt-lab:prompt-runner`"). For v1 this is accepted: prompt-analysis / creation / adaptation / library degrade gracefully (those references are optional next-steps); prompt-testing's core loop depends on runner/judge agents that only exist in Claude Code — its SKILL.md is still ported, and Codex/OpenCode agents will improvise executors, which is acceptable for a personal first port. A follow-up may generalize the wording.

## 4. Migration mechanics (Claude plugins)

1. `git mv orchestrator plugins/orchestrator && git mv prompt-lab plugins/prompt-lab`.
2. `.claude-plugin/marketplace.json`: sources → `./plugins/orchestrator`, `./plugins/prompt-lab`.
3. Version bumps so installed caches refresh: orchestrator `1.0.0 → 1.0.1`, prompt-lab `0.1.0 → 0.1.1` (in each `plugin.json`).
4. Verify: `claude plugin validate ./plugins/orchestrator && claude plugin validate ./plugins/prompt-lab` exit 0; then `claude plugin update orchestrator@gt-plugins` / `prompt-lab@gt-plugins` (or the `/plugin` UI) picks up the new versions.
5. Nothing else moves: `docs/`, `.superpowers/` stay put.

## 5. Codex port

- `plugins/prompt-lab/.codex-plugin/plugin.json`:
  ```json
  {
    "name": "prompt-lab",
    "version": "0.1.1",
    "description": "Prompt engineering lab: analyze, improve, create, test, adapt, and catalog prompts. Companion to promptingguide.ai.",
    "skills": "./skills/"
  }
  ```
  No `hooks` key (Codex ignores our `additionalContext` shape — a registered hook would add trust prompts for zero effect). No commands (deprecated concept in Codex; skills cover it).
- `.agents/plugins/marketplace.json` — Codex-native catalog, mirroring the Claude marketplace schema (name/owner/plugins with `source` paths). Lists `prompt-lab` only (orchestrator is Claude-specific: its value is subagent orchestration wired to Claude Code's Task tool).
- **Schema caveat:** the exact `.agents/plugins/marketplace.json` field set is documented as Claude-compatible but will be confirmed against `codex plugin marketplace add` behavior during implementation; fallback is Codex's legacy read of `.claude-plugin/marketplace.json` (which would also expose orchestrator — acceptable fallback, not preferred).
- Registration & verification (live, Codex 0.142.4 installed): `codex plugin marketplace add ~/Development/claude-plugins` → install prompt-lab via `/plugins` or CLI → confirm the five skills appear (`/skills` or `codex exec` probe) → keep it installed (this is the user's real setup).
- Both plugin.json versions (Claude + Codex manifests) are bumped in lockstep by convention, documented in README.

## 6. OpenCode port

- `opencode/skills/<name>` — relative symlinks into `plugins/prompt-lab/skills/<name>` (git commits symlinks; OpenCode reads live so links stay fresh with the repo).
- Install: `make install-opencode` creates per-skill symlinks `~/.config/opencode/skills/<name>` → `<repo>/opencode/skills/<name>` (dereferenced target works through the chain). Non-destructive: refuses to overwrite an existing non-symlink entry; `make uninstall-opencode` removes only links pointing into this repo.
- Alternative documented in `opencode/README.md`: set `OPENCODE_CONFIG_DIR=<repo>/opencode` instead of symlinking.
- Verification deferred until OpenCode is installed; the Makefile target is testable now (creates links; `ls -l` shows resolution; `SKILL.md` reachable through the chain).

## 7. Tooling & docs

- `Makefile` targets:
  - `validate` — `claude plugin validate` for every dir under `plugins/` with a `.claude-plugin/`, `jq .` on all four JSON manifests, and a symlink-integrity check for `opencode/skills/*` (each must resolve to an existing `SKILL.md`).
  - `install-codex` — wraps `codex plugin marketplace add <repo path>` (idempotent; prints next steps).
  - `install-opencode` / `uninstall-opencode` — symlink management described in §6.
- Root `README.md` rewritten: repo purpose (personal multi-tool extensions), a plugin × tool support matrix, per-tool install instructions, and the dual-manifest convention for adding new plugins.
- `opencode/README.md` and `codex/README.md` — one short file each: what belongs here, how it's consumed.

## 8. Risks & accepted trade-offs

- `.agents/plugins/marketplace.json` exact schema unverified until live registration (fallback documented in §5).
- Codex plugin cache behavior with a dual-manifest directory is verified by the live smoke; if Codex chokes on the extra `.claude-plugin/` dir (unlikely — it's the documented legacy format), fallback is a Codex-specific package under `codex/`.
- prompt-lab skills carry Claude-specific cross-references (accepted for v1, see §3 note).
- Existing installed Claude plugins keep working through the move only after the version bump + update — a one-time action on this machine, documented in the plan.

## 9. Out of scope (this iteration)

- Porting orchestrator anywhere (Claude-specific by nature).
- OpenCode JS plugins, commands, agents; Codex rules/subagent roles — dirs exist as documented homes, content comes later.
- Any CI, publishing automation, or registry submission.
- Generalizing prompt-lab skill wording away from Claude-specific references.

## 10. Verification plan (summary)

1. `make validate` green after migration.
2. Claude: both plugins update to bumped versions and commands still work (`/prompt-lab:analyze` smoke on one fixture).
3. Codex: marketplace registered, prompt-lab installed, 5 skills listed, one skill invoked end-to-end (`codex exec` probe using prompt-analysis on a fixture).
4. OpenCode: `make install-opencode` produces resolving symlinks (full runtime check deferred until the tool is installed).
