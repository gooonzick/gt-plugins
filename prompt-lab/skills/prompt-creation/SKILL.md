---
name: prompt-creation
description: Use when the user wants a new prompt built from a task description ("напиши промпт для…", "create a prompt that…"). Interview-driven builder that selects techniques and assembles a structured prompt.
argument-hint: "[task description]"
---

# Prompt Creation

Build a prompt from a task description: interview → technique selection → assembly → self-review.

## Workflow

1. **Interview** — one question at a time, skip anything already answered by the task description:
   1. Task & success criteria: what must the output achieve; how would the user tell a good output from a bad one?
   2. Target model & runtime: which model; API call, agent system, or chat UI? (Determines vendor idioms and whether prefill/structured outputs are available.)
   3. Inputs: what does the prompt receive, how variable is it, is any of it untrusted?
   4. Output: exact format the consumer expects (schema, length, language).
   5. Constraints: tone, forbidden content, latency/token budget.
   6. Examples: does the user have real input→output pairs? (2–3 good ones beat any instruction.)
2. **Select techniques.** Read `../prompt-analysis/references/techniques.md`; pick only techniques whose "apply when" matches — cite each choice with its link. Read the matching vendor file (`../prompt-analysis/references/claude.md` or `gpt.md`) for idioms.
3. **Assemble** on this skeleton, omitting sections the task doesn't need:
   - Role (only if load-bearing) → Context → Task instruction → Constraints → Examples → Output format → Edge-case handling (including untrusted-input fencing when applicable).
4. **Self-review** the draft against `../prompt-analysis/references/rubric.md`. Fix anything scoring below 4 before showing it.
5. **Present:** the prompt in a copyable block + per-section rationale (one line each: why it's there, which technique) + open risks.
6. **Offer next steps:** `/prompt-lab:test` to verify on real runs; `/prompt-lab:save` to store in the library.

## Rules

- No decorative roles, no filler ("You are a helpful assistant" is banned unless justified).
- Templated slots use `{{variable_name}}` and each is listed with an example value.
- Write the prompt in the language the runtime expects (usually English), even if the conversation is not.
