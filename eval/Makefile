# Define variables
CC_BASELINE = ../build_baseline/bin/clang
CC_MODIFIED = ../build_modified/bin/clang
CFLAGS = -target riscv32-unknown-elf -march=rv32imafd --sysroot=$(RISCV32_TOOLCHAIN)/riscv32-unknown-elf -O2 -S
SRC_DIR = tests
BUILD_DIR = build
SOURCES = $(wildcard $(SRC_DIR)/*.c)
OUTPUT_BASELINE = $(SOURCES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%-baseline.s)
OUTPUT_MODIFIED = $(SOURCES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%-modified.s)

# Default target: run both compilers and then call eval.py for either all files or a single file
all: $(if $(FILE), $(BUILD_DIR)/$(FILE)-baseline.s $(BUILD_DIR)/$(FILE)-modified.s, $(OUTPUT_BASELINE) $(OUTPUT_MODIFIED))
	python3 eval.py $(if $(FILE), $(BUILD_DIR)/$(FILE)-baseline.s $(BUILD_DIR)/$(FILE)-modified.s)

# Rule for generating baseline .s files
$(BUILD_DIR)/%-baseline.s: $(SRC_DIR)/%.c
	$(CC_BASELINE) $(CFLAGS) $< -o $@

# Rule for generating modified .s files
$(BUILD_DIR)/%-modified.s: $(SRC_DIR)/%.c
	$(CC_MODIFIED) $(CFLAGS) $< -o $@

# Clean target
clean:
	rm -f $(OUTPUT_BASELINE) $(OUTPUT_MODIFIED)

.PHONY: all clean


