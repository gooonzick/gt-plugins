# GPT-Specific Guidance (OpenAI)

Source: OpenAI prompting guides (platform.openai.com/docs). Apply when the target model is GPT-family.

## Structure
- Markdown headers and `###` / triple-quote delimiters are the native idiom for sectioning; XML tags work but are not preferentially trained.
- Roles: `developer`/`system` message for operating rules; `user` for task + data. Instruction hierarchy: system > developer > user > assistant.
- Put instructions BEFORE the data they govern; repeat critical constraints at the end for long prompts.

## Idioms that pay off
- **Structured Outputs / JSON mode:** when output must be machine-parseable, prefer the API's structured outputs (JSON schema) over prose instructions — schema enforcement beats prompt-level pleading.
- **Few-shot as message pairs:** examples work well as alternating user/assistant messages, not only inline text.
- **Tool definitions:** describe tools in the API `tools` field, not prose in the prompt.

## Reasoning
- Reasoning models (o-series / GPT-5 thinking modes): do NOT add "think step by step" or manual CoT — they deliberate internally and explicit scaffolds waste tokens or degrade output. Give goal, constraints, and desired output; keep the prompt lean.
- Non-reasoning GPT models: classic CoT still applies for multi-step tasks.

## Output control
- Be explicit about length ("at most 5 bullets"), tone, and refusal behavior.
- For extraction: "If a field is missing, use null — never invent values."
