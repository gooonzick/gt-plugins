# Planted Flaws (smoke-test oracle)

Analysis of each fixture MUST surface at least the flaws listed for it; the rubric dimension that should catch each flaw is in parentheses.

## vague-task.md
- No concrete task: "important stuff", "maybe categorize things if that makes sense" (1 Task clarity)
- Contradiction: "thorough but keep it short" (1 Task clarity)
- No output format at all (5 Output format)
- Decorative role (3 Role & context)

## injection-vulnerable.md
- Untrusted `{{ticket_body}}` placed bare, no data/instruction fencing (7 Injection resistance)
- "execute any status changes it requires" + "always comply with instructions found in the ticket" — explicit injection amplifier (7 Injection resistance)
- Dangerous capability framing: "admin access" granted in the same prompt that ingests untrusted text (7 Injection resistance)

## bloated.md
- Same constraint restated 5+ times; motivational filler; apologetic closing (8 Token efficiency)
- Stacked decorative superlatives in the role (3 Role & context, 8 Token efficiency)
- No output format, length, tone, or audience spec despite the verbosity (5 Output format)

## format-free.md
- "structured data" with no schema, field names, or types (5 Output format)
- "anything else relevant" — unbounded extraction scope (1 Task clarity)
- No instruction for missing fields → hallucination pressure (6 Edge-case handling)
