#!/usr/bin/env bash
# PostToolUse advisory hook: when a prompt-like file is written/edited,
# inject a soft hint that prompt-lab commands are available.
# Silent (exit 0, no output) for everything else. Never blocks.
set -uo pipefail

input=$(cat)

file_path=$(printf '%s' "$input" | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get("tool_input", {}).get("file_path", ""))
except Exception:
    pass
' 2>/dev/null)

[ -n "$file_path" ] || exit 0

base=$(basename "$file_path")
lower=$(printf '%s' "$base" | tr '[:upper:]' '[:lower:]')

match=0
case "$file_path" in
  */prompts/*) match=1 ;;
  */agents/*.md) match=1 ;;
esac
case "$lower" in
  skill.md|claude.md|agents.md|*.prompt.md|*.prompt.txt|*prompt*.md|*prompt*.txt|*prompt*.py|*prompt*.ts|system*.md|system*.txt) match=1 ;;
esac

[ "$match" -eq 1 ] || exit 0

printf '%s\n' '{"hookSpecificOutput": {"hookEventName": "PostToolUse", "additionalContext": "A prompt-like file was just edited. If the user is iterating on this prompt'"'"'s wording or behavior, you may offer /prompt-lab:analyze or /prompt-lab:test for it. Do not interrupt unrelated work (mechanical renames, formatting, non-prompt content)."}}'
exit 0
