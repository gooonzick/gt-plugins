# Claude-Specific Guidance (Anthropic)

Source: Anthropic prompt engineering docs (platform.claude.com/docs). Apply when the target model is Claude.

## Structure
- Use XML tags to delimit parts: `<instructions>`, `<context>`, `<example>`, `<document>`, `<output_format>`. Claude is trained to respect them; they beat markdown headers for data/instruction separation.
- System prompt: role and stable operating rules. Task-specific detail goes in the user turn.
- Long context: put long documents FIRST, instructions and question AFTER them — recall is better when the query is near the end.

## Idioms that pay off
- **Prefill:** start the assistant turn with the beginning of the desired output (`{` for JSON, `<result>` for tagged output) to lock format and skip preamble. API-only feature.
- **Examples in `<example>` tags**, several wrapped in `<examples>` — the single highest-leverage technique for format fidelity.
- **Explicitness:** modern Claude follows instructions literally; say exactly what you want, including what NOT to do and what to do instead ("do X; if Y, do Z" — not "don't do Y").
- **Allow uncertainty:** explicitly permit "I don't know" to cut hallucination.

## Reasoning
- Claude with extended thinking: don't scaffold manual CoT ("think step by step") — request thinking effort or just present the problem; manual CoT scaffolds can degrade native deliberation.
- Claude without extended thinking: classic CoT ("reason in <thinking> tags, answer in <answer> tags") still helps on multi-step tasks.

## Output control
- Describe the exact schema and show one example of the filled shape.
- To suppress chattiness: "Output only the JSON. No preamble, no code fences."
