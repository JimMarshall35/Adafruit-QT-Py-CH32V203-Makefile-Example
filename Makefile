# Toolchain
CC      = riscv-none-elf-gcc
OBJCOPY = riscv-none-elf-objcopy

# Target
TARGET = USART_Printf

# ===== Select startup file here =====
# Options: D6, D8, D8W
STARTUP ?= D6

STARTUP_FILE = SRC/Startup/startup_ch32v20x_$(STARTUP).S

# Flags
CFLAGS = -march=rv32imac_zicsr_zifencei -mabi=ilp32 -msmall-data-limit=8 -msave-restore \
         -Os -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections \
         -fno-common -Wunused -Wuninitialized -g

LDFLAGS = -T SRC/Ld/Link.ld -nostartfiles -Xlinker --gc-sections -Wl,-Map,"USART_Printf.map" --specs=nano.specs --specs=nosys.specs

# Include paths
LIBRARY_INCLUDES = \
	-ISRC/Core \
	-ISRC/Debug \
	-ISRC/Peripheral/inc

EXAMPLE_INCLUDES = -IUSART_Printf/User

INCLUDES = $(LIBRARY_INCLUDES) $(EXAMPLE_INCLUDES)

# Source files
LIBRARY_C = \
	$(wildcard SRC/Core/*.c) \
	$(wildcard SRC/Debug/*.c) \
	$(wildcard SRC/Peripheral/src/*.c) \
	
EXAMPLE_C = $(wildcard USART_Printf/User/*.c)

SRC_C = $(LIBRARY_C) $(EXAMPLE_C)

SRC_S = $(STARTUP_FILE)

SRCS = $(SRC_C) $(SRC_S)

# Object files
OBJS = $(SRCS:.c=.o)
OBJS := $(OBJS:.S=.o)

# Default target
all: $(TARGET).elf

# Link
$(TARGET).elf: $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) $(OBJS) -o $@ 

# Compile C
%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

# Compile ASM
%.o: %.S
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

# Binary output (optional)
$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

# Clean
clean:
	rm -f $(OBJS) $(TARGET).elf $(TARGET).bin $(TARGET).map

.PHONY: all clean