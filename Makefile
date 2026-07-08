REPO_ROOT := $(shell git rev-parse --show-toplevel)
OPENCODE_SKILLS_DIR := $(HOME)/.config/opencode/skills
OPENCODE_SRC := $(REPO_ROOT)/opencode/skills

.PHONY: validate install-codex install-opencode uninstall-opencode

validate:
	@set -e; for p in plugins/*/; do \
	  if [ -d "$$p.claude-plugin" ]; then \
	    echo "== claude validate $$p"; claude plugin validate "$$p"; \
	  fi; \
	done
	@jq . .claude-plugin/marketplace.json > /dev/null && echo "claude marketplace.json OK"
	@jq . .agents/plugins/marketplace.json > /dev/null && echo "codex marketplace.json OK"
	@jq . plugins/prompt-lab/.codex-plugin/plugin.json > /dev/null && echo "codex plugin.json OK"
	@set -e; for s in opencode/skills/*; do \
	  [ -f "$$s/SKILL.md" ] || { echo "BROKEN symlink: $$s"; exit 1; }; \
	done; echo "opencode symlinks OK"

install-codex:
	codex plugin marketplace add "$(REPO_ROOT)"
	@echo "Registered. Install/manage plugins via: codex -> /plugins"

install-opencode:
	@mkdir -p "$(OPENCODE_SKILLS_DIR)"
	@set -e; for s in $(OPENCODE_SRC)/*; do \
	  name=$$(basename "$$s"); dest="$(OPENCODE_SKILLS_DIR)/$$name"; \
	  if [ -L "$$dest" ]; then ln -sfn "$$s" "$$dest"; echo "updated $$name"; \
	  elif [ -e "$$dest" ]; then echo "SKIP $$name: exists and is not a symlink"; \
	  else ln -s "$$s" "$$dest"; echo "linked $$name"; fi; \
	done

uninstall-opencode:
	@set -e; for s in $(OPENCODE_SRC)/*; do \
	  name=$$(basename "$$s"); dest="$(OPENCODE_SKILLS_DIR)/$$name"; \
	  if [ -L "$$dest" ] && [ "$$(readlink "$$dest")" = "$$s" ]; then \
	    rm "$$dest"; echo "removed $$name"; \
	  fi; \
	done
