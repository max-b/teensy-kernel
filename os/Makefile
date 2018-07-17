BUILD_DIR=../build/os

BOOTLOADER_SRCS := $(wildcard *.asm)
BOOTLOADER_OBJS := $(patsubst %.asm, %.o, $(BUILD_DIR)/$(BOOTLOADER_SRCS))

all: $(BOOTLOADER_OBJS)

$(BUILD_DIR)/%.o: %.asm
	nasm -f bin $< -o $@

clean: 
	rm -f $(BUILD_DIR)/*
