# ----- AI commit Make targets (BSD/GNU make safe) -----
SHELL := /bin/bash
.SILENT:

MODEL ?= qwen2.5-coder:7b
OLLAMA_URL ?= http://localhost:11434
MAX_DIFF_CHARS ?= 20000
USE_AI ?= 1

export MODEL OLLAMA_URL MAX_DIFF_CHARS USE_AI

.PHONY: commit-ai push-ai

commit-ai:
	@../Scripts/ai-commit.sh

push-ai: commit-ai
	@bash -lc 'set -euo pipefail; \
	branch="$$(git rev-parse --abbrev-ref HEAD)"; \
	if ! git rev-parse --abbrev-ref --symbolic-full-name "@{u}" >/dev/null 2>&1; then \
	  echo "Setting upstream for $$branch ..."; \
	  git push --set-upstream origin "$$branch"; \
	else \
	  git push; \
	fi'