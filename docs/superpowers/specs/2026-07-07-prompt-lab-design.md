# prompt-lab — Claude Code plugin for prompt engineering (Design)

**Date:** 2026-07-07
**Status:** Approved design, pending implementation plan
**Location:** `gt-plugins/prompt-lab/` (this repo), registered in `.claude-plugin/marketplace.json`

## 1. Overview

`prompt-lab` is a skills-first Claude Code plugin for working with prompts: analyze, improve, create, test, adapt, audit, and catalog them. It is positioned as a **companion plugin to [promptingguide.ai](https://www.promptingguide.ai)** — its methodology is grounded in the guide's technique catalog plus current Anthropic/OpenAI prompting guidance.

**Key differentiator:** improvements are *verified by execution*, not vibes. The improve loop runs both the original and the improved prompt against generated test cases using clean-context subagents, then scores outputs with a blind judge.

### Decisions log (from brainstorming, 2026-07-07)

| Decision | Choice |
|---|---|
| Audience | Personal use first, built for open-source publication |
| Prompt types | Prompts embedded in code, agent artifacts (CLAUDE.md, skills, subagent prompts), standalone prompt texts |
| Methodology | promptingguide.ai techniques + Anthropic/OpenAI best practices |
| Dynamic testing | Yes — real runs via subagents, A/B with blind judging |
| Architecture | Skills-first: knowledge in skills, thin commands, agents for execution, one hook |
| Name | `prompt-lab` |
| Library storage | `$PROMPT_LIBRARY_DIR`, default `~/prompt-library` (user data, never in the plugin repo) |
| Hook behavior | Soft advisory hint on prompt-file edits; non-blocking |

## 2. Repository layout

```
prompt-lab/
  .claude-plugin/
    plugin.json                 # name, version, description, author, keywords
  README.md                     # English; positioning, install, command reference
  skills/
    prompt-analysis/
      SKILL.md                  # rubric-based analysis methodology
      references/
        rubric.md               # scoring dimensions, what-good-looks-like, smells
        techniques.md           # distilled technique catalog w/ promptingguide.ai links
        claude.md               # Anthropic-specific guidance (XML tags, prefill, system prompts)
        gpt.md                  # OpenAI-specific guidance
    prompt-creation/
      SKILL.md                  # builder: interview → technique selection → assembly
    prompt-testing/
      SKILL.md                  # test matrix, run protocol, blind judging, A/B
    prompt-adaptation/
      SKILL.md                  # cross-model porting + token compression
    prompt-library/
      SKILL.md                  # storage conventions, save/find workflows
  commands/
    analyze.md  improve.md  create.md  test.md
    audit.md    adapt.md    save.md    find.md
  agents/
    prompt-runner.md            # clean-context executor
    prompt-judge.md             # blind A/B scorer
  hooks/
    hooks.json                  # PostToolUse on Write|Edit
    scripts/
      prompt-file-hint.sh       # detects prompt-like files, emits soft hint
  examples/
    known-bad/                  # fixture prompts for smoke-testing the plugin itself
```

Marketplace registration: add a `prompt-lab` entry to `gt-plugins/.claude-plugin/marketplace.json` (`source: "./prompt-lab"`).

## 3. Skills

Skills hold all methodology. Commands only route into them. Each SKILL.md keeps its body lean and points to `references/` files that are loaded on demand.

### 3.1 `prompt-analysis` (core skill)

**Triggers:** user asks to analyze/review/critique a prompt, asks why a prompt underperforms, or a command invokes it.

**Workflow:**
1. Ingest the prompt (file path or inline text). Detect its kind: system prompt, chat prompt, agent artifact (CLAUDE.md / SKILL.md / subagent), templated prompt (has `{{vars}}`, f-string slots, etc.).
2. Load `references/rubric.md`; load the vendor file (`claude.md` / `gpt.md`) matching the prompt's target model when known.
3. Score each rubric dimension 1–5 with evidence quotes from the prompt.
4. Rank findings by expected impact; for each, cite the relevant technique from `references/techniques.md` with its promptingguide.ai link.
5. Output a structured report: score table → top findings with concrete rewrite suggestions → optional "quick wins" diff.

**Rubric dimensions** (`references/rubric.md`), each with "what good looks like", common smells, and scoring anchors:
- Clarity & specificity of the task
- Structure & formatting (sections, delimiters, XML tags vs markdown)
- Role & context adequacy
- Examples quality (few-shot: count, diversity, format consistency)
- Output format specification
- Edge-case & failure-mode handling
- Injection resistance / instruction hierarchy (for prompts that consume untrusted input)
- Token efficiency (redundancy, dead weight)
- Model fit (uses target model's idioms; no counterproductive carryovers from other vendors)

**`references/techniques.md`:** distilled from the guide's `pages/techniques/` — zero-shot, few-shot, chain-of-thought, self-consistency, tree-of-thoughts, RAG, ReAct, reflexion, etc. Each entry: one-paragraph essence, "apply when…" criteria, link to the corresponding promptingguide.ai page. This file is a *curated distillation written for the plugin*, not a copy of guide pages.

### 3.2 `prompt-creation`

**Triggers:** user wants a new prompt from a task description.

**Workflow:** short interview (one question at a time): task & success criteria → target model & runtime (API, agent, chat) → inputs and their variability → output format consumers expect → constraints/tone → available examples. Then select techniques via `techniques.md`, assemble on a standard skeleton (role → context → task → constraints → examples → output format → edge-case instructions), self-review the draft against the rubric, present with rationale per section. Offer to hand off to `prompt-testing` for verification.

### 3.3 `prompt-testing`

**Triggers:** user wants to test a prompt or compare two versions.

**Workflow:**
1. Derive success criteria (ask the user if not inferable).
2. Build a test matrix: typical inputs, edge cases, adversarial cases (including prompt-injection probes when the prompt consumes untrusted input). For templated prompts, fill variables with realistic values.
3. **Cost gate:** present the run plan (`N cases × M versions = K runs`) and get explicit confirmation before spawning anything.
4. Spawn one `prompt-runner` per (version, case) — parallel where possible. Runners receive the prompt and input verbatim, in clean context.
5. Feed outputs to `prompt-judge` with deterministic counterbalanced A/B labels (alternated by case parity, mapping withheld from the judge) and the success criteria. The judge never learns which version is "improved".
6. Report: per-case verdict table, per-criterion scores, aggregate win/loss, notable failures with quotes.

**Limitation (documented in README):** runs execute on Claude via Claude Code subagents. For prompts targeting other vendors the run is an approximation; cross-vendor execution is out of scope for v1.

### 3.4 `prompt-adaptation`

Two modes:
- **Port:** translate a prompt between model idioms (e.g. GPT → Claude: markdown headers → XML tags, add prefill guidance, restructure system content; and the reverse). Uses the vendor reference files.
- **Compress:** reduce tokens while preserving behavior — remove redundancy, collapse verbose instructions, keep load-bearing constraints. Always offers a verification run via `prompt-testing` (original vs compressed) so compression is evidence-checked.

### 3.5 `prompt-library`

Storage: `$PROMPT_LIBRARY_DIR` (default `~/prompt-library`). One markdown file per prompt:

```markdown
---
name: short-kebab-slug
description: one-line summary
tags: [extraction, json, production]
model: claude-sonnet-5
version: 2
tested: 2026-07-07        # last verified via prompt-testing
source: repo-or-context   # where it came from / where it is used
---

<the prompt text>
```

- `save`: dedupe by name (offer update vs new), bump `version` on update.
- `find`: grep-based search over frontmatter and body; present ranked matches.
- The library directory is user data — created on first save, suggested to be a git repo, never part of the plugin.

## 4. Commands (thin routers)

| Command | Args | Routes to |
|---|---|---|
| `/prompt-lab:analyze` | file path or inline text | prompt-analysis |
| `/prompt-lab:improve` | file path or inline text | prompt-analysis → rewrite → offer verification via prompt-testing |
| `/prompt-lab:create` | task description | prompt-creation |
| `/prompt-lab:test` | file [`--vs` file2] | prompt-testing |
| `/prompt-lab:audit` | path (default `.`) | scan for embedded prompts → inventory → batch prompt-analysis |
| `/prompt-lab:adapt` | file `--to claude\|gpt\|compress` | prompt-adaptation |
| `/prompt-lab:save` | file or last discussed prompt | prompt-library |
| `/prompt-lab:find` | query | prompt-library |

Each command file: frontmatter (`description`, `argument-hint`), a short body that names the skill to invoke and passes `$ARGUMENTS`. No methodology lives in commands.

**`audit` specifics:** heuristic scan (string literals with instruction-like phrasing, variables/keys named `*prompt*`/`*system*`/`instructions`, prompt-bearing YAML/JSON, `messages=[{"role": "system"...`). Present the inventory table (file, line, kind, confidence) and let the user confirm/trim it **before** batch analysis — this is the false-positive gate and the cost gate in one.

## 5. Agents

### `prompt-runner`
Clean-context executor. Receives: the prompt under test (verbatim) + one test input. Instructions: treat the prompt as your operating instructions, process the input, return the raw response only — no meta-commentary, no analysis, no mention of being a test. This isolation prevents our critique from leaking into runs.

### `prompt-judge`
Blind scorer. Receives: task description, success criteria, and outputs labeled A/B (labels alternated deterministically by case parity — not randomized — with the mapping withheld from the judge). Returns structured JSON: per-criterion score (1–5) per output, verdict (`A|B|tie`) with one-sentence reason. Never told which output came from which version.

## 6. Hook

`hooks/hooks.json`: `PostToolUse` on `Write|Edit`. The script `prompt-file-hint.sh` checks the edited file path against prompt-file patterns:
- paths: `prompts/`, `**/agents/*.md`, `**/skills/**/SKILL.md`
- names: `*.prompt.md`, `*prompt*`, `CLAUDE.md`, `system*.txt|md`

On match it emits **additional context** (soft hint): "A prompt-like file changed — consider offering `/prompt-lab:analyze` if the user is iterating on it." It never blocks, never auto-runs analysis, and matches conservatively (path/name only, no content sniffing in v1). Disable by removing the hook entry.

## 7. Improve loop (the flagship flow)

```
/prompt-lab:improve prompt.md
  1. prompt-analysis → scored report
  2. rewrite → v2 with per-change rationale (technique citations)
  3. offer verification (skippable):
     prompt-testing → test matrix → cost gate →
     runners (v1 & v2 × cases, parallel) → blind judge →
     evidence table: where v2 wins / loses / ties
  4. if v2 loses on some cases → iterate on those findings (max 2 iterations, then report honestly)
  5. present final diff + evidence; user applies
```

## 8. Edge cases

- **Templated prompts:** detect `{{var}}` / `${var}` / f-string / Jinja slots; test cases must bind realistic values; analysis notes unbound assumptions.
- **Very long prompts (>~2k lines):** analyze section-by-section, then synthesize.
- **Non-English prompts:** analysis report and rewrites stay in the prompt's language.
- **Cost control:** any flow that spawns runners shows the run plan and waits for confirmation first.
- **Audit noise:** confidence-ranked inventory, user confirms before batch analysis.

## 9. Testing the plugin itself

`examples/known-bad/` holds fixture prompts with planted, documented flaws (vague task, no output format, injection-vulnerable, bloated). Smoke flow after changes: run `analyze` on each fixture and check the rubric catches the planted flaws; run one `improve` with verification end-to-end; run `audit` against a small fixture tree; `save`/`find` round-trip.

## 10. Out of scope (v1)

- MCP server / any compiled component.
- Executing prompts on non-Claude models (adapt *produces* text for other vendors; runs happen on Claude).
- Team/shared library sync, CI integration, prompt-registry backends.
- Auto-lint hook mode (hook stays advisory).

## 11. Publication notes

- README in English: positioning as promptingguide.ai companion, install via `gt-plugins` marketplace, command reference, the improve-loop story, testing limitation note.
- `plugin.json` keywords: prompt-engineering, prompts, analysis, testing, promptingguide.
- Techniques file cites and links the guide rather than copying its content wholesale (MIT-licensed, but curation beats duplication).
