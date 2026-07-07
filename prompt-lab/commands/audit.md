---
description: Find prompts embedded in a codebase, inventory them, batch-analyze on confirmation
argument-hint: "[path, default .]"
---

Audit the codebase at the path below (default: current directory) for embedded prompts.

1. **Scan** with Grep/Glob for high-signal markers:
   - identifiers matching `prompt`, `system_prompt`, `instructions`, `persona` assigned string literals;
   - message arrays: `role.{0,3}system`, `role.{0,3}user` near string content;
   - instruction-like literals: strings >200 chars containing "You are", "Your task", "Respond with", "Always", "Never";
   - prompt-bearing files: `*.prompt.*`, `prompts/**`, YAML/JSON keys named `prompt|system|instructions`.
2. **Inventory:** table of file:line · kind (system/template/chat) · first 60 chars · confidence (high/medium/low). Sort by confidence.
3. **Gate:** ask the user to confirm/trim the list — never batch-analyze unconfirmed findings (this is both the false-positive filter and the cost gate).
4. **Batch-analyze** confirmed entries with the prompt-lab:prompt-analysis skill (compact mode: scores + top-2 findings each), then a summary table ranked by lowest score.

Path:

$ARGUMENTS
