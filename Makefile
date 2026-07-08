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
	@set -e; for m in plugins/*/.codex-plugin/plugin.json; do \
	  [ -e "$$m" ] || continue; \
	  jq . "$$m" > /dev/null && echo "codex plugin.json OK: $$m"; \
	done
	@set -e; for s in opencode/skills/*; do \
	  [ -e "$$s" ] || continue; \
	  [ -f "$$s/SKILL.md" ] || { echo "BROKEN symlink: $$s"; exit 1; }; \
	done; echo "opencode symlinks OK"

install-codex:
	codex plugin marketplace add "$(REPO_ROOT)"
	@echo "Registered. Install with: codex plugin add prompt-lab@gt-plugins (or codex -> /plugins)"

install-opencode:
	@mkdir -p "$(OPENCODE_SKILLS_DIR)"
	@set -e; for s in $(OPENCODE_SRC)/*; do \
	  [ -e "$$s" ] || continue; \
	  name=$$(basename "$$s"); dest="$(OPENCODE_SKILLS_DIR)/$$name"; \
	  if [ -L "$$dest" ]; then ln -sfn "$$s" "$$dest"; echo "updated $$name"; \
	  elif [ -e "$$dest" ]; then echo "SKIP $$name: exists and is not a symlink"; \
	  else ln -s "$$s" "$$dest"; echo "linked $$name"; fi; \
	done

uninstall-opencode:
	@set -e; for s in $(OPENCODE_SRC)/*; do \
	  [ -e "$$s" ] || continue; \
	  name=$$(basename "$$s"); dest="$(OPENCODE_SKILLS_DIR)/$$name"; \
	  if [ -L "$$dest" ] && [ "$$(readlink "$$dest")" = "$$s" ]; then \
	    rm "$$dest"; echo "removed $$name"; \
	  fi; \
	done
