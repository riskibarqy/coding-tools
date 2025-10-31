# ----- Robust AI commit with ticket prefix (BSD/GNU make compatible) -----
SHELL := /bin/bash
.SILENT:

MODEL ?= llama3.2:3b-instruct
OLLAMA_URL ?= http://localhost:11434
MAX_DIFF_CHARS ?= 20000
USE_AI ?= 1

.PHONY: commit-ai push-ai

commit-ai:
	@bash -lc 'set -euo pipefail; \
	if git diff --quiet && git diff --cached --quiet; then \
	  echo "No changes to commit."; exit 0; \
	fi; \
	git add -A; \
	branch="$$(git rev-parse --abbrev-ref HEAD)"; \
	ticket="$$(echo "$$branch" | grep -oE "[A-Z]{2,}-[0-9]+" || true)"; \
	scope_raw="$$(echo "$$branch" | cut -d"/" -f1 | tr "[:upper:]" "[:lower:]")"; \
	case "$$scope_raw" in \
	  feat|feature) scope="new-feature" ;; \
	  fix|bugfix)   scope="fix" ;; \
	  hotfix)       scope="hotfix" ;; \
	  refactor)     scope="refactor" ;; \
	  docs|doc)     scope="docs" ;; \
	  test|tests)   scope="test" ;; \
	  ci)           scope="ci" ;; \
	  build)        scope="build" ;; \
	  perf)         scope="perf" ;; \
	  *)            scope="misc" ;; \
	esac; \
	files_changed="$$(git diff --cached --name-only)"; \
	num_files="$$(printf "%s\n" "$$files_changed" | sed "/^$$/d" | wc -l | tr -d " ")"; \
	stats="$$(git diff --cached --numstat | awk "{add+=\$$1; del+=\$$2} END{printf(\"+%d/-%d\",add+0,del+0)}")"; \
	diff_raw="$$(git diff --cached --text --unified=0)"; \
	diff_trunc="$$(printf "%s" "$$diff_raw" | head -c $(MAX_DIFF_CHARS))"; \
	if [ "$$(printf "%s" "$$diff_raw" | wc -c)" -gt "$(MAX_DIFF_CHARS)" ]; then \
	  diff_trunc="$$diff_trunc\n\n[diff truncated to $(MAX_DIFF_CHARS) chars]"; \
	fi; \
	msg=""; \
	if [ "$(USE_AI)" = "1" ] && curl -sf "$(OLLAMA_URL)/api/tags" >/dev/null; then \
	  prompt="$$(printf "Write a SINGLE-LINE git commit message (<=72 chars), imperative mood.\nMake it concise and specific. Do NOT include ticket IDs or brackets.\nChanged files (%s %s):\n%s\n\nDiff:\n%s\n" "$$num_files" "$$stats" "$$files_changed" "$$diff_trunc")"; \
	  json="$$(printf "%s" "$$prompt" | jq -Rs .)"; \
	  msg="$$(curl -s "$(OLLAMA_URL)/api/generate" -H "Content-Type: application/json" -d "{\"model\":\"$(MODEL)\",\"prompt\":$$json,\"stream\":false}" | jq -r ".response" || true)"; \
	fi; \
	if [ -z "$$msg" ] || [ "$$msg" = "null" ]; then \
	  if echo "$$files_changed" | grep -qiE "(^|/)(README|.*\.md)$$"; then kind="docs"; \
	  elif echo "$$files_changed" | grep -qiE "\.test\.(go|js|ts)$$"; then kind="test"; \
	  else kind="update"; fi; \
	  msg="$$kind $$num_files file(s) $$stats"; \
	fi; \
	msg="$$(printf "%s" "$$msg" | head -n1 | sed "s/^[[:space:]]*//;s/[[:space:]]*$$//" | cut -c1-72)"; \
	if [ -z "$$ticket" ]; then ticket="NO-TICKET"; fi; \
	final_msg="$$ticket [$$scope] $$msg"; \
	echo "📝 $$final_msg"; \
	git commit -m "$$final_msg"'

push-ai:
	@$(MAKE) commit-ai
	@bash -lc 'set -euo pipefail; \
	branch="$$(git rev-parse --abbrev-ref HEAD)"; \
	if ! git rev-parse --abbrev-ref --symbolic-full-name "@{u}" >/dev/null 2>&1; then \
	  echo "Setting upstream for $$branch ..."; \
	  git push --set-upstream origin "$$branch"; \
	else \
	  git push; \
	fi'