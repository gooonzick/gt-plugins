# Multi-tool Repo Reorganization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganize gt-plugins into a multi-tool monorepo (Claude Code + Codex + OpenCode) with dual-manifest plugin packages, and ship the first port: prompt-lab skills available in Codex and OpenCode.

**Architecture:** Cross-tool plugin packages live in `plugins/` (one dir per plugin, one manifest per supported tool side by side). Claude Code consumes `.claude-plugin/marketplace.json` (sources moved to `./plugins/*`, versions bumped to refresh caches). Codex consumes a new `.agents/plugins/marketplace.json` catalog plus a `.codex-plugin/plugin.json` manifest inside prompt-lab. OpenCode reads live symlinks: `opencode/skills/*` → plugin skills, installed into `~/.config/opencode/skills/` by a Makefile target.

**Tech Stack:** git mv, JSON manifests, POSIX symlinks, Makefile, `claude plugin validate`, `codex plugin marketplace` CLI (Codex 0.142.4 installed; OpenCode NOT installed — its runtime check is deferred).

**Spec:** `docs/superpowers/specs/2026-07-08-multitool-repo-design.md` (approved 2026-07-08).

## Global Constraints

- Repo root: `/Users/george.tsamaladze/Development/claude-plugins`. All commands run from there. Work directly on `main` (user-approved for this repo; commit after every task, do NOT push).
- Version bumps are exact: orchestrator `1.0.0 → 1.0.1`, prompt-lab `0.1.0 → 0.1.1`. The Claude AND Codex manifests of prompt-lab carry the SAME version string `0.1.1`.
- Marketplace `source` values must start with `./` (Claude requirement) — new values are `./plugins/orchestrator` and `./plugins/prompt-lab`.
- Symlinks inside the repo are RELATIVE (`../../plugins/...`); symlinks created in `~/.config/opencode/skills/` are ABSOLUTE (point into this repo).
- `make install-opencode` must never overwrite an existing non-symlink entry; `make uninstall-opencode` removes only links that point into this repo.
- After every task: `claude plugin validate ./plugins/orchestrator` and `claude plugin validate ./plugins/prompt-lab` must exit 0 (from Task 1 onward).
- Makefile recipes MUST be indented with literal TAB characters, not spaces — `make` fails otherwise.
- Do not touch `docs/`, `.superpowers/`, or plugin content files (skills/commands/agents/hooks bodies) except where a task explicitly says so.

---

### Task 1: Move Claude plugins into `plugins/` and bump versions

**Files:**
- Move: `orchestrator/` → `plugins/orchestrator/`, `prompt-lab/` → `plugins/prompt-lab/` (git mv, whole trees)
- Modify: `.claude-plugin/marketplace.json` (two `source` values)
- Modify: `plugins/orchestrator/.claude-plugin/plugin.json` (version)
- Modify: `plugins/prompt-lab/.claude-plugin/plugin.json` (version)

**Interfaces:**
- Produces: plugin roots `plugins/orchestrator` and `plugins/prompt-lab` — every later task references these paths; prompt-lab version string `0.1.1` (Task 2's Codex manifest must match it).

- [ ] **Step 1: Move the plugin directories**

```bash
mkdir -p plugins
git mv orchestrator plugins/orchestrator
git mv prompt-lab plugins/prompt-lab
```

- [ ] **Step 2: Update marketplace sources**

Replace the full contents of `.claude-plugin/marketplace.json` with:

```json
{
  "name": "gt-plugins",
  "description": "Personal Claude Code plugins by George Tsamaladze",
  "owner": {
    "name": "George Tsamaladze",
    "email": "tsamaladze@gmail.com"
  },
  "plugins": [
    {
      "name": "orchestrator",
      "source": "./plugins/orchestrator",
      "description": "Orchestrator pattern: routing-only main agent with code-locator / code-researcher / implementer sub-agents",
      "category": "workflow"
    },
    {
      "name": "prompt-lab",
      "source": "./plugins/prompt-lab",
      "description": "Prompt engineering lab: analyze, improve, create, test, adapt, and catalog prompts — with evidence-based A/B verification",
      "category": "workflow"
    }
  ]
}
```

- [ ] **Step 3: Bump orchestrator version**

In `plugins/orchestrator/.claude-plugin/plugin.json` change only the version line: `"version": "1.0.0"` → `"version": "1.0.1"`. Everything else stays byte-identical.

- [ ] **Step 4: Bump prompt-lab version**

In `plugins/prompt-lab/.claude-plugin/plugin.json` change only the version line: `"version": "0.1.0"` → `"version": "0.1.1"`. Everything else stays byte-identical.

- [ ] **Step 5: Validate**

Run: `jq . .claude-plugin/marketplace.json > /dev/null && claude plugin validate ./plugins/orchestrator && claude plugin validate ./plugins/prompt-lab && test ! -d orchestrator && test ! -d prompt-lab && echo ALL-OK`
Expected: two "Validation passed" lines and `ALL-OK`; exit 0.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "refactor: move plugins into plugins/ and bump versions for cache refresh"
```

---

### Task 2: Codex manifests + `codex/` placeholder

**Files:**
- Create: `plugins/prompt-lab/.codex-plugin/plugin.json`
- Create: `.agents/plugins/marketplace.json`
- Create: `codex/README.md`

**Interfaces:**
- Consumes: `plugins/prompt-lab` path and version `0.1.1` (Task 1).
- Produces: Codex catalog at `.agents/plugins/marketplace.json` (used by Task 4's `install-codex` and Task 6's live registration); dual-manifest convention documented for Task 5's README.

- [ ] **Step 1: Write the Codex plugin manifest**

Write `plugins/prompt-lab/.codex-plugin/plugin.json`:

```json
{
  "name": "prompt-lab",
  "version": "0.1.1",
  "description": "Prompt engineering lab: analyze, improve, create, test, adapt, and catalog prompts. Companion to promptingguide.ai.",
  "skills": "./skills/"
}
```

Note: intentionally NO `hooks` key (Codex ignores our PostToolUse `additionalContext` shape) and no commands (deprecated in Codex; skills cover the functionality).

- [ ] **Step 2: Write the Codex marketplace catalog**

Write `.agents/plugins/marketplace.json`:

```json
{
  "name": "gt-plugins",
  "description": "Personal Codex plugins by George Tsamaladze",
  "owner": {
    "name": "George Tsamaladze",
    "email": "tsamaladze@gmail.com"
  },
  "plugins": [
    {
      "name": "prompt-lab",
      "source": "./plugins/prompt-lab",
      "description": "Prompt engineering lab: analyze, improve, create, test, adapt, and catalog prompts — with evidence-based A/B verification"
    }
  ]
}
```

(orchestrator is deliberately absent: it is Claude-specific — wired to Claude Code's Task tool.)

- [ ] **Step 3: Write the codex/ placeholder**

Write `codex/README.md`:

```markdown
# codex/

Home for Codex-specific artifacts that don't fit the cross-tool package model in `plugins/`:
execpolicy rules (`rules/*.rules`), subagent role definitions (`agents/*.toml`), hooks.

Empty for now. Cross-tool plugins (with a `.codex-plugin/plugin.json` manifest) live in `plugins/`
and are distributed via the catalog at `.agents/plugins/marketplace.json` — register it with
`make install-codex` or `codex plugin marketplace add <repo path>`.
```

- [ ] **Step 4: Validate**

Run: `jq . plugins/prompt-lab/.codex-plugin/plugin.json > /dev/null && jq . .agents/plugins/marketplace.json > /dev/null && claude plugin validate ./plugins/prompt-lab && echo ALL-OK`
Expected: "Validation passed" and `ALL-OK` (the extra `.codex-plugin/` dir must not break Claude validation); exit 0.

- [ ] **Step 5: Commit**

```bash
git add plugins/prompt-lab/.codex-plugin .agents codex
git commit -m "feat: Codex manifest for prompt-lab and .agents marketplace catalog"
```

---

### Task 3: OpenCode skills symlinks

**Files:**
- Create: `opencode/skills/prompt-analysis`, `prompt-creation`, `prompt-testing`, `prompt-adaptation`, `prompt-library` (relative symlinks)
- Create: `opencode/README.md`

**Interfaces:**
- Consumes: `plugins/prompt-lab/skills/<name>/` directories (Task 1 paths).
- Produces: `opencode/skills/*` entries consumed by Task 4's `install-opencode`/`validate` targets.

- [ ] **Step 1: Create the symlinks**

```bash
mkdir -p opencode/skills
cd opencode/skills
for s in prompt-analysis prompt-creation prompt-testing prompt-adaptation prompt-library; do
  ln -s "../../plugins/prompt-lab/skills/$s" "$s"
done
cd ../..
```

- [ ] **Step 2: Write opencode/README.md**

Write `opencode/README.md`:

````markdown
# opencode/

OpenCode artifacts. OpenCode has no marketplace — it reads plain directories, live (no install cache),
so everything here is consumed via symlinks.

- `skills/` — symlinks into `plugins/*/skills/`. OpenCode reads the Agent Skills standard
  (`SKILL.md` with `name` + `description`) natively; directory name must equal the skill's `name`.

## Install

From the repo root:

```
make install-opencode
```

This symlinks each `opencode/skills/<name>` into `~/.config/opencode/skills/<name>`.
It never overwrites an existing non-symlink entry. Remove with `make uninstall-opencode`.

Alternative (no symlinks): add `export OPENCODE_CONFIG_DIR="$HOME/Development/claude-plugins/opencode"`
to your shell profile — OpenCode searches that directory like a project `.opencode/`.

Future homes (create when needed): `commands/`, `agents/`, `plugins/` (JS/TS), `tools/`, `themes/`.
````

- [ ] **Step 3: Verify symlink resolution**

Run: `for s in opencode/skills/*; do test -f "$s/SKILL.md" || { echo "BROKEN: $s"; exit 1; }; done && ls -l opencode/skills | grep -c '^l'`
Expected: no BROKEN lines; final output `5` (five symlinks); exit 0.

- [ ] **Step 4: Commit**

```bash
git add opencode
git commit -m "feat: OpenCode skills dir with live symlinks to prompt-lab skills"
```

---

### Task 4: Makefile

**Files:**
- Create: `Makefile`

**Interfaces:**
- Consumes: `plugins/*/` layout (Task 1), `.agents/plugins/marketplace.json` (Task 2), `opencode/skills/*` symlinks (Task 3).
- Produces: `make validate`, `make install-codex`, `make install-opencode`, `make uninstall-opencode` — referenced by both READMEs and Task 6.

- [ ] **Step 1: Write the Makefile**

Write `Makefile` (CRITICAL: recipe lines must be indented with a literal TAB character, not spaces):

```make
REPO_ROOT := $(shell git rev-parse --show-toplevel)
OPENCODE_SKILLS_DIR := $(HOME)/.config/opencode/skills
OPENCODE_SRC := $(REPO_ROOT)/opencode/skills

.PHONY: validate install-codex install-opencode uninstall-opencode

validate:
	@set -e; for p in plugins/*/; do \
	  if [ -d "$$p.claude-plugin" ]; then \
	    echo "== claude validate $$p"; claude plugin validate "$$p"; \
	  fi; \
	done
	@jq . .claude-plugin/marketplace.json > /dev/null && echo "claude marketplace.json OK"
	@jq . .agents/plugins/marketplace.json > /dev/null && echo "codex marketplace.json OK"
	@jq . plugins/prompt-lab/.codex-plugin/plugin.json > /dev/null && echo "codex plugin.json OK"
	@set -e; for s in opencode/skills/*; do \
	  [ -f "$$s/SKILL.md" ] || { echo "BROKEN symlink: $$s"; exit 1; }; \
	done; echo "opencode symlinks OK"

install-codex:
	codex plugin marketplace add "$(REPO_ROOT)"
	@echo "Registered. Install/manage plugins via: codex -> /plugins"

install-opencode:
	@mkdir -p "$(OPENCODE_SKILLS_DIR)"
	@set -e; for s in $(OPENCODE_SRC)/*; do \
	  name=$$(basename "$$s"); dest="$(OPENCODE_SKILLS_DIR)/$$name"; \
	  if [ -L "$$dest" ]; then ln -sfn "$$s" "$$dest"; echo "updated $$name"; \
	  elif [ -e "$$dest" ]; then echo "SKIP $$name: exists and is not a symlink"; \
	  else ln -s "$$s" "$$dest"; echo "linked $$name"; fi; \
	done

uninstall-opencode:
	@set -e; for s in $(OPENCODE_SRC)/*; do \
	  name=$$(basename "$$s"); dest="$(OPENCODE_SKILLS_DIR)/$$name"; \
	  if [ -L "$$dest" ] && [ "$$(readlink "$$dest")" = "$$s" ]; then \
	    rm "$$dest"; echo "removed $$name"; \
	  fi; \
	done
```

- [ ] **Step 2: Test `make validate`**

Run: `make validate`
Expected: two "Validation passed" blocks, three "OK" JSON lines, `opencode symlinks OK`; exit 0.

- [ ] **Step 3: Test install/uninstall-opencode against a throwaway HOME**

```bash
TMP_HOME=$(mktemp -d)
make install-opencode HOME="$TMP_HOME"
ls -l "$TMP_HOME/.config/opencode/skills" | grep -c '^l'      # expect: 5
test -f "$TMP_HOME/.config/opencode/skills/prompt-analysis/SKILL.md" && echo RESOLVES
touch "$TMP_HOME/.config/opencode/skills/blocker"
make install-opencode HOME="$TMP_HOME"                         # expect: 5x "updated", no SKIP (blocker untouched, different name)
make uninstall-opencode HOME="$TMP_HOME"
ls "$TMP_HOME/.config/opencode/skills"                         # expect: only "blocker" remains
rm -rf "$TMP_HOME"
```

Expected: `5`, `RESOLVES`, uninstall leaves only `blocker`; every make exits 0.

- [ ] **Step 4: Commit**

```bash
git add Makefile
git commit -m "feat: Makefile with validate and per-tool install targets"
```

---

### Task 5: Root README rewrite

**Files:**
- Modify: `README.md` (full replacement)

**Interfaces:**
- Consumes: Makefile target names (Task 4), catalog paths (Task 2), install flows (Tasks 2–4).

- [ ] **Step 1: Replace README.md**

Replace the full contents of `README.md` with:

````markdown
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
````

- [ ] **Step 2: Verify and commit**

Run: `make validate` (still green — README change must not affect it).

```bash
git add README.md
git commit -m "docs: rewrite README for multi-tool layout"
```

---

### Task 6: Live verification (Claude update + Codex registration + OpenCode install)

**Files:**
- No planned file changes; fixes committed as `fix: <what>` if a step fails.

**Interfaces:**
- Consumes: everything.

- [ ] **Step 1: Refresh Claude installs**

```bash
claude plugin marketplace update gt-plugins
claude plugin update orchestrator@gt-plugins
claude plugin update prompt-lab@gt-plugins
```

Expected: both plugins update to 1.0.1 / 0.1.1 from the new `./plugins/*` paths. If the update
subcommands differ in this CLI version, discover with `claude plugin --help` and use the equivalent;
record what you ran.

- [ ] **Step 2: Claude smoke**

Run: `claude -p "/prompt-lab:analyze plugins/prompt-lab/examples/known-bad/vague-task.md"`
Expected: rubric report appears (scores table + findings) — proves the moved plugin still works end-to-end.

- [ ] **Step 3: Register the Codex marketplace**

Run: `make install-codex`
Expected: registration succeeds. Then check `codex plugin marketplace list` shows `gt-plugins`.
If `codex plugin marketplace add` rejects the local path or the `.agents/plugins/marketplace.json`
schema, capture the exact error, adjust the catalog file to the schema the error demands
(field-level fix only), commit as `fix: adjust codex marketplace schema`, and retry.

- [ ] **Step 4: Install prompt-lab in Codex and verify skills**

Discover the non-interactive install command via `codex plugin --help` (expected shape:
`codex plugin install prompt-lab@gt-plugins` or similar). If no such subcommand exists (the
interactive `/plugins` flow can't run headlessly), verify discoverability instead:
`codex plugin marketplace list` / `codex plugin list` must name prompt-lab, and note in the
report that the actual install click is left to the user.
After install (whichever path worked), probe skills:

```bash
codex exec --skip-git-repo-check "List the names of your available skills, one per line, nothing else."
```

Expected: the five prompt-lab skills (prompt-analysis, prompt-creation, prompt-testing,
prompt-adaptation, prompt-library) appear. Record actual output honestly; partial visibility is a
finding, not a pass.

- [ ] **Step 5: Real OpenCode install**

Run: `make install-opencode && ls -l ~/.config/opencode/skills && test -f ~/.config/opencode/skills/prompt-analysis/SKILL.md && echo RESOLVES`
Expected: 5 links, `RESOLVES`. (OpenCode itself is not installed — runtime check deferred; this
verifies the install mechanism.) Leave the links in place — this is the user's real setup.

- [ ] **Step 6: Closing commit**

```bash
git commit --allow-empty -m "chore: multi-tool reorg verified (claude update, codex marketplace, opencode links)"
```
