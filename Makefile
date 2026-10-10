CC ?= gcc
BUILD_DIR ?= build
TARGET := $(BUILD_DIR)/titan-studymate
SOURCE := src/titan_studymate.S

.PHONY: all run clean

all: $(TARGET)

$(TARGET): $(SOURCE)
	@mkdir -p $(BUILD_DIR)
	$(CC) -no-pie -Wl,-z,noexecstack $(SOURCE) -o $(TARGET)

run: $(TARGET)
	./$(TARGET)

clean:
	rm -rf $(BUILD_DIR)
