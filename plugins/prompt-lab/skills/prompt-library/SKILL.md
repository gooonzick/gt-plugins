---
name: prompt-library
description: Use when the user wants to save a prompt to their personal library or find/reuse a previously saved prompt. Markdown-with-frontmatter storage in $PROMPT_LIBRARY_DIR.
argument-hint: "[save <file|last prompt> | find <query>]"
---

# Prompt Library

Personal prompt catalog. Location: `"${PROMPT_LIBRARY_DIR:-$HOME/prompt-library}"` — resolve it once per session via `echo "${PROMPT_LIBRARY_DIR:-$HOME/prompt-library}"`.

## File format

One markdown file per prompt, named `<slug>.md`:

```markdown
---
name: short-kebab-slug
description: one-line summary of what the prompt does
tags: [extraction, json, production]
model: claude-sonnet-5
version: 1
tested: 2026-07-07        # date of last prompt-testing verification, or "never"
source: repo/path or context where it came from
---

<the prompt text, verbatim>
```

## Save workflow

1. Identify the prompt: explicit file argument, or the prompt most recently discussed in conversation (confirm which).
2. Create the library dir if missing: `mkdir -p "${PROMPT_LIBRARY_DIR:-$HOME/prompt-library}"`. On first creation, suggest (don't force): `git init` inside it for versioning.
3. Slug from the prompt's purpose (kebab-case, ≤5 words). If `<slug>.md` exists: show the existing entry, ask update vs new name. On update: bump `version`, keep `name`, refresh `tested` only if a test actually ran.
4. Fill every frontmatter field — `tags` from task domain + output format + usage context; never leave placeholders.
5. Write the file, confirm with the path.

## Find workflow

1. Search: `grep -ril "<query>" "${PROMPT_LIBRARY_DIR:-$HOME/prompt-library}"` plus a frontmatter scan of `name`/`description`/`tags` for the query terms.
2. Rank: frontmatter hits above body hits; recent `tested` dates break ties.
3. Present top matches as `name — description — tags — version`; on selection, show the full prompt and offer: copy as-is, adapt (`/prompt-lab:adapt`), or analyze (`/prompt-lab:analyze`).
4. No matches: say so and list available tags (`grep -h "^tags:" …`), so the user can re-query.

## Rules

- The library is user data: never store it inside a plugin/marketplace repo; never commit to it without the user asking.
- Never overwrite an entry silently — dedupe flow above is mandatory.
