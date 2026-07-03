# gt-plugins

Personal Claude Code plugin marketplace.

## Install

```
claude plugin marketplace add ~/Development/claude-plugins
claude plugin install orchestrator@gt-plugins
```

## Update after changing a plugin

Bump `version` in the plugin's `plugin.json`, commit, then:

```
claude plugin marketplace update gt-plugins
claude plugin update orchestrator@gt-plugins
```

## Plugins

- **orchestrator** — the main agent only routes, decides, and synthesizes; all file reading and code editing is delegated to model-routed sub-agents (`code-locator`/haiku, `code-researcher`/opus, `implementer`/sonnet). Routing rules are injected every session via a SessionStart hook.
