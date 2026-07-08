# codex/

Home for Codex-specific artifacts that don't fit the cross-tool package model in `plugins/`:
execpolicy rules (`rules/*.rules`), subagent role definitions (`agents/*.toml`), hooks.

Empty for now. Cross-tool plugins (with a `.codex-plugin/plugin.json` manifest) live in `plugins/`
and are distributed via the catalog at `.agents/plugins/marketplace.json` — register it with
`make install-codex` or `codex plugin marketplace add <repo path>`.
