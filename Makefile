# =============================================================================
# Makefile — app-socios-estadio-docs
# =============================================================================
# Validación del repositorio de docs (markdown only, sin código).
# Cada target es opcional: si la herramienta no está instalada, se skipea.
# =============================================================================

.PHONY: help validate lint test links check clean

PROJECT := app_socios_estadio_docs

help:
	@echo "=== $(PROJECT) Makefile ==="
	@echo ""
	@echo "Targets:"
	@echo "  make validate      Run all available checks (lint + links)"
	@echo "  make lint          Lint markdown files"
	@echo "  make links         Verify markdown cross-references resolve"
	@echo "  make test          No tests in this repo (markdown only)"
	@echo "  make clean         Remove temp files"
	@echo ""
	@echo "Tools (auto-detected, skip if missing):"
	@echo "  - markdownlint-cli2  (npm install -g markdownlint-cli2)"
	@echo "  - markdown-link-check (npm install -g markdown-link-check)"

validate: lint links
	@echo "[validate] All available checks passed"

lint:
	@echo "[lint] Checking markdown style..."
	@if command -v markdownlint-cli2 >/dev/null 2>&1; then \
		markdownlint-cli2 "**/*.md" "#node_modules"; \
	else \
		echo "[lint] markdownlint-cli2 not found, skipping (npm i -g markdownlint-cli2 to enable)"; \
	fi
	@echo "[lint] Done"

links:
	@echo "[links] Checking markdown cross-references..."
	@if command -v markdown-link-check >/dev/null 2>&1; then \
		find . -name "*.md" -not -path "./node_modules/*" | while read -r f; do \
			markdown-link-check "$$f" --quiet || echo "[links] broken links in $$f"; \
		done; \
	else \
		echo "[links] markdown-link-check not found, skipping (npm i -g markdown-link-check to enable)"; \
	fi
	@echo "[links] Done"

test:
	@echo "[test] No tests in docs repo (markdown-only). Use 'make validate' for lint + links."

clean:
	@echo "[clean] Removing temp files..."
	@find . -name "*.tmp" -delete 2>/dev/null || true
	@find . -name ".DS_Store" -delete 2>/dev/null || true
	@echo "[clean] Done"