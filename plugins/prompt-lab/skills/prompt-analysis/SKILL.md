---
name: prompt-analysis
description: Use when the user asks to analyze, review, critique, or score a prompt, or asks why a prompt underperforms. Rubric-based analysis grounded in promptingguide.ai techniques and vendor best practices.
argument-hint: "[file path or inline prompt text]"
---

# Prompt Analysis

Analyze a prompt against the rubric and produce a scored, evidence-based report.

## Workflow

1. **Ingest.** Get the prompt from the argument (file path → read it; inline text → use as-is). If neither, ask the user for one.
2. **Classify.** Determine:
   - Kind: system prompt / chat prompt / agent artifact (CLAUDE.md, SKILL.md, subagent prompt) / templated prompt (contains `{{var}}`, `${var}`, f-string `{var}`, or Jinja slots).
   - Target model, if stated or inferable from context. If unknown, note it and analyze vendor-neutrally.
   - Whether it consumes untrusted input (user messages, scraped content, tool output) — this activates the injection-resistance dimension.
3. **Load references.** Always read `references/rubric.md`. Read `references/claude.md` or `references/gpt.md` only when the target model is known. Read `references/techniques.md` when drafting findings (step 5).
4. **Score.** Rate every applicable rubric dimension 1–5. Quote evidence from the prompt for every score below 4. Skip inapplicable dimensions (e.g., injection resistance for a prompt with no untrusted input) and say why.
5. **Findings.** Rank problems by expected impact on output quality. For each: what's wrong → why it matters → concrete fix (rewritten fragment, not advice) → technique citation with its promptingguide.ai link from `references/techniques.md` when one applies.
6. **Report** in the format below. Keep the report in the prompt's own language.

## Report format

```
## Prompt analysis: <name or file>
Kind: <kind> · Target model: <model or "unknown"> · Untrusted input: <yes/no>

### Scores
| Dimension | Score | Evidence (if <4) |
|---|---|---|
...

### Top findings
1. <problem> — <impact>. Fix: <rewritten fragment>. Technique: <name> (<link>)
...

### Quick wins
- <one-line mechanical fixes: typos, dead weight, formatting>
```

## Rules

- Evidence over opinion: every criticism quotes the prompt.
- Fixes are rewrites, not advice ("replace X with Y", never "consider clarifying").
- Long prompts (>2000 lines): analyze section-by-section, then synthesize one report.
- Never execute the prompt here — running is `prompt-testing`'s job. Offer `/prompt-lab:test` at the end when behavior questions remain open.
