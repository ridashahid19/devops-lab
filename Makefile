# Makefile - Lab 02 Task 4 (assessed)
# Every recipe line begins with a real TAB. Check with: cat -A Makefile

SRC_DIR := src
OUT_DIR := out

# TODO 1 / 2: no filename written by hand
SOURCES := $(wildcard $(SRC_DIR)/*.txt)
OUTPUTS := $(patsubst $(SRC_DIR)/%.txt,$(OUT_DIR)/%.txt,$(SOURCES))

# TODO 3: every action target
.PHONY: all check build test clean ci show

# The first target in the file is what a bare `make` runs.
all: test

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

# TODO 4: pattern rule - $< is the input, $@ the output, | = order-only
$(OUT_DIR)/%.txt: $(SRC_DIR)/%.txt | $(OUT_DIR)
	@echo "  BUILD $< -> $@"
	@tr '[:lower:]' '[:upper:]' < $< > $@

# TODO 5: fail loudly when there is nothing to build
check:
	@test -d $(SRC_DIR) || { echo "ERROR: source directory $(SRC_DIR) is missing"; exit 1; }
	@test $(words $(SOURCES)) -gt 0 || { echo "ERROR: no .txt files found in $(SRC_DIR)"; exit 1; }
	@echo "check: found $(words $(SOURCES)) source file(s) in $(SRC_DIR)"

# The whole build stage. This one line is the lesson.
build: $(OUTPUTS)

# TODO 6: fail when any lowercase letter remains
test: build
	@if grep -l '[a-z]' $(OUTPUTS) >/dev/null 2>&1; then \
		echo "TEST FAILED: lowercase characters remain"; exit 1; \
	fi
	@echo "TEST PASSED"

# TODO 7: remove the output directory
clean:
	rm -rf $(OUT_DIR)

# A build server's entry point: clean, verify, then build and test.
ci: clean check test

show:
	@echo "SOURCES = $(SOURCES)"
	@echo "OUTPUTS = $(OUTPUTS)"

count: build  ## count the source files
	@ls -1 $(SRC_DIR)/*.txt | wc -l
