# opencode/

OpenCode artifacts. OpenCode has no marketplace — it reads plain directories, live (no install cache),
so everything here is consumed via symlinks.

- `skills/` — symlinks into `plugins/*/skills/`. OpenCode reads the Agent Skills standard
  (`SKILL.md` with `name` + `description`) natively; directory name must equal the skill's `name`.

## Install

From the repo root:

```
make install-opencode
```

This symlinks each `opencode/skills/<name>` into `~/.config/opencode/skills/<name>`.
It never overwrites an existing non-symlink entry. Remove with `make uninstall-opencode`.

Alternative (no symlinks): add `export OPENCODE_CONFIG_DIR="$HOME/Development/claude-plugins/opencode"`
to your shell profile — OpenCode searches that directory like a project `.opencode/`.

Future homes (create when needed): `commands/`, `agents/`, `plugins/` (JS/TS), `tools/`, `themes/`.
