# Makefile - Lab 05: Make owns the order, npm owns the recipe.

SRC_DIR := src
OUT_DIR := out

SOURCES := $(wildcard $(SRC_DIR)/*.md)
OUTPUTS := $(patsubst $(SRC_DIR)/%.md,$(OUT_DIR)/%.html,$(SOURCES))

.PHONY: all check deps build test package clean ci show

all: test

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

node_modules: package-lock.json
	npm ci
	@touch node_modules

deps: node_modules  ## install exactly what the lock file says

$(OUT_DIR)/%.html: $(SRC_DIR)/%.md package-lock.json | $(OUT_DIR) node_modules
	@echo "  BUILD $< -> $@"
	@npm run --silent build -- $< $@

check:
	@test -d $(SRC_DIR) || { echo "ERROR: source directory $(SRC_DIR) is missing"; exit 1; }
	@test $(words $(SOURCES)) -gt 0 || { echo "ERROR: no .md files found in $(SRC_DIR)"; exit 1; }
	@echo "check: found $(words $(SOURCES)) source file(s) in $(SRC_DIR)"

build: $(OUTPUTS)

test: build  ## run the test suite against what was built
	@npm test --silent

package: test  ## produce the versioned artifact
	npm pack

clean:  ## remove all generated files
	rm -rf $(OUT_DIR) *.tgz

ci: clean deps check test package  ## the build server entry point

show:
	@echo "SOURCES = $(SOURCES)"
	@echo "OUTPUTS = $(OUTPUTS)"
