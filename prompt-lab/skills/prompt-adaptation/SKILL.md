---
name: prompt-adaptation
description: Use when the user wants to port a prompt between model vendors (GPT↔Claude) or compress a prompt to fewer tokens without changing behavior.
argument-hint: "[prompt file] --to claude|gpt|compress"
---

# Prompt Adaptation

Two modes, chosen by the `--to` argument (ask if absent).

## Mode: port (`--to claude` / `--to gpt`)

1. Read the prompt and both vendor references: `../prompt-analysis/references/claude.md` and `../prompt-analysis/references/gpt.md`.
2. Translate idioms, don't transliterate text. Typical moves:
   - → Claude: markdown sections carrying data/instruction separation → XML tags; add prefill suggestion for strict formats; move stable rules into the system prompt; long documents before instructions.
   - → GPT: XML scaffolding → markdown/delimiters; strict output formats → recommend Structured Outputs at the API level (note it — the prompt alone can't enforce it); instructions before data, critical constraints repeated at the end.
   - Both directions: strip manual CoT if the target is a reasoning model; keep it if not.
3. Preserve behavior-bearing content exactly: constraints, edge-case rules, example semantics. Flag anything untranslatable (e.g., prefill has no GPT equivalent) in a "porting notes" list.
4. Present: ported prompt + porting notes (what changed and why, per vendor reference).

## Mode: compress (`--to compress`)

1. Classify every sentence: behavior-bearing (changes outputs) vs dead weight (repetition, filler, hedging, decorative roles).
2. Rewrite: merge duplicate constraints, collapse verbose phrasing, trim examples to the minimum that still spans the distribution. Never drop: edge-case rules, output format, injection fencing.
3. Report token counts before/after (estimate: chars/4) and a removed-content list so the user can veto cuts.
4. **Offer verification:** run original vs compressed through `prompt-lab:prompt-testing` (A/B) — compression without evidence is a guess. On behavior regression, restore the responsible cut.

## Rules

- Porting and compression never "improve" the prompt beyond the requested transformation — suggest `/prompt-lab:improve` separately if you spot unrelated problems.
