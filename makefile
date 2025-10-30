# ---- AI Commit with Ollama (no cmai; guaranteed format) ----
# Usage:
#   make commit-ai
#   make commit-ai MODEL=deepseek-r1:7b
#
# Requires: curl, jq, a running Ollama server (default http://localhost:11434)

MODEL ?= llama3.2:3b-instruct
OLLAMA_URL ?= http://localhost:11434
MAX_DIFF_CHARS ?= 20000

.PHONY: commit-ai push-ai

commit-ai:
	@set -eu; \
	# 0) ensure there is something to commit
	if [ -z "$$(git status --porcelain)" ]; then echo "No changes to commit."; exit 0; fi; \
	\
	# 1) stage everything (or edit to 'git add -p')
	git add -A; \
	\
	# 2) derive ticket & scope from branch: e.g. feat/WIT-123-dev
	branch=$$(git rev-parse --abbrev-ref HEAD); \
	ticket=$$(echo "$$branch" | grep -oE 'WIT-[0-9]+' || true); \
	scope_raw=$$(echo "$$branch" | cut -d'/' -f1 | tr '[:upper:]' '[:lower:]'); \
	# normalize scope to a known set
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
	\
	# 3) collect safe diff summary (avoid binary junk)
	files_changed=$$(git diff --cached --name-only); \
	num_files=$$(printf "%s\n" "$$files_changed" | sed '/^$$/d' | wc -l | tr -d ' '); \
	stats=$$(git diff --cached --numstat | awk '{add+=$$1; del+=$$2} END{printf("+%d/-%d",add+0,del+0)}'); \
	diff_raw=$$(git diff --cached --text --unified=0); \
	diff_trunc=$$(printf "%s" "$$diff_raw" | head -c $(MAX_DIFF_CHARS)); \
	if [ $$(printf "%s" "$$diff_raw" | wc -c) -gt $(MAX_DIFF_CHARS) ]; then \
	  diff_trunc="$$diff_trunc\n\n[diff truncated to $(MAX_DIFF_CHARS) chars]"; \
	fi; \
	\
	# 4) build a compact prompt for a one-line message (<=72 chars)
	prompt=$$(printf "Write a SINGLE-LINE git commit message (<=72 chars), imperative mood.\n\
Make it concise and specific. Do NOT include ticket IDs or brackets.\n\
Examples: 'adjust API payload validation', 'fix nil deref in consumer loop'\n\
Changed files (%s %s):\n%s\n\nDiff:\n%s\n" \
	"$$num_files" "$$stats" "$$files_changed" "$$diff_trunc"); \
	json=$$(printf '%s' "$$prompt" | jq -Rs .); \
	\
	# 5) ensure Ollama is reachable
	curl -s $(OLLAMA_URL)/api/tags >/dev/null || { echo "Ollama not reachable at $(OLLAMA_URL)"; exit 1; }; \
	\
	# 6) call Ollama; get a one-liner; fallback if empty
	msg=$$(curl -s $(OLLAMA_URL)/api/generate \
	  -H 'Content-Type: application/json' \
	  -d "{\"model\":\"$(MODEL)\",\"prompt\":$$json,\"stream\":false}" \
	  | jq -r '.response' || true); \
	if [ -z "$$msg" ] || [ "$$msg" = "null" ]; then msg="update project files"; fi; \
	msg=$$(printf "%s" "$$msg" | head -n1 | sed 's/^\s*//;s/\s*$$//'); \
	\
	# 7) assemble final message: WIT-123 [fix] your message
	prefix=$${ticket:-NO-TICKET}; \
	final_msg="$$prefix [$$scope] $$msg"; \
	echo "📝 $$final_msg"; \
	git commit -m "$$final_msg"

# Optional: commit + push in one shot
push-ai: commit-ai
	@git push