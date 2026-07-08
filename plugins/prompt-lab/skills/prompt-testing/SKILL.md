---
name: prompt-testing
description: Use when the user wants to test a prompt against real runs, compare two prompt versions (A/B), or verify that an "improved" prompt actually beats the original. Generates a test matrix, executes via clean-context runner agents, scores with a blind judge.
argument-hint: "[prompt file] [--vs other-version-file]"
---

# Prompt Testing

Evidence-based prompt evaluation: test matrix → confirmed run plan → clean-context runs → blind judging → verdict table.

## Workflow

1. **Ingest.** One prompt (single-version scoring) or two (`--vs`: A/B comparison). Read files if paths given.
2. **Success criteria.** Derive 2–5 measurable criteria from the prompt's own stated goal and output format. Show them to the user; adjust on feedback. No vague criteria ("is good") — each must be checkable against a single output.
3. **Test matrix.** Build 5–8 cases:
   - 3–4 typical inputs spanning the real input distribution;
   - 1–2 edge cases (empty fields, maximum length, ambiguous phrasing);
   - 1–2 adversarial cases; if the prompt consumes untrusted input, one MUST be a prompt-injection probe (an instruction to ignore the prompt embedded in the data).
   - Templated prompts: bind every `{{var}}`-style slot with realistic values per case; list the bindings.
4. **Cost gate (mandatory).** Present: criteria, the case list, and the plan `N cases × M versions = K runner calls + N judge calls`. Proceed only on explicit user confirmation.
5. **Run.** For every (version, case): spawn `prompt-lab:prompt-runner` with exactly:

   ```
   === PROMPT UNDER TEST ===
   <version text>
   === TEST INPUT ===
   <case>
   ```

   Spawn independent runs in parallel where the platform allows.
6. **Judge.** One `prompt-lab:prompt-judge` call per case, with exactly:

   ```
   === TASK ===
   <what the prompt is supposed to accomplish>
   === SUCCESS CRITERIA ===
   1. <criterion>
   2. ...
   === OUTPUT A ===
   <output>
   === OUTPUT B ===
   <output — omit this block in single-version mode>
   ```

   **Blinding:** for even-numbered cases label the original "A" and the challenger "B"; for odd-numbered cases, swap. Keep the mapping in your notes; never include it in judge input. Single-version mode: only OUTPUT A, verdict pass/fail.
7. **Report.**

   ```
   ## Test report: <prompt name>
   Criteria: 1. … 2. …
   | Case | Winner (real names, unblinded) | Scores orig | Scores challenger | Note |
   Aggregate: challenger wins X / loses Y / ties Z.
   Notable failures: <case> — <quoted output fragment> — <which criterion failed>
   ```

   Recommend: adopt / iterate / keep original — based on the table, not on impressions.

## Rules

- Never skip the cost gate, even for 2-case runs.
- Runner outputs are evidence: quote them verbatim in "notable failures", never paraphrase.
- Limitation (state it when relevant): runs execute on Claude; for prompts targeting other vendors this is an approximation.
