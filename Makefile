

PROJECT_NAME = stepper
TARGET = $(PROJECT_NAME).elf
BUILD = debug

# Source files:
SRCS = \
	main.c \
	system_stm32f1xx.c \
	stm32f1xx_it.c \
	stm32f1xx_hal_msp.c

SRCDIR = src
INCDIR = inc

BINDIR = bin
OBJDIR = obj
DEPDIR = dep

# HAL Peripheral Library
PERIPH_LIB = Libraries

# Used programs:
CC = arm-none-eabi-gcc
GDB = arm-none-eabi-gdb
OBJCOPY = arm-none-eabi-objcopy
OBJDUMP = arm-none-eabi-objdump
SIZE = arm-none-eabi-size

# Compilation settings:
CFLAGS  = -std=gnu11
CFLAGS += -mlittle-endian -mcpu=cortex-m3 -mthumb
CFLAGS += -Wall -Wstrict-prototypes -fsingle-precision-constant
#CFLAGS += -ffunction-sections -fdata-sections
CFLAGS += -g
#CFLAGS += -Os
CFLAGS += -O0

##### defining used MCU (instead of in file stm32f00x.h): -DSTM32F051x8
CFLAGS += -I$(INCDIR)
CFLAGS += -I$(PERIPH_LIB)
CFLAGS += -I$(PERIPH_LIB)/CMSIS/Include
CFLAGS += -I$(PERIPH_LIB)/CMSIS/ST/Include
CFLAGS += -I$(PERIPH_LIB)/STM32F1xx_HAL_Driver/Inc
CFLAGS += -I$(PERIPH_LIB)/STM32F1xx_HAL_Driver/Inc/Legacy
CFLAGS += -DUSE_HAL_DRIVER # to include file stm32f1xx_hal.h


# Settings of linker
LDFLAGS =  -mcpu=cortex-m3 -mthumb
LDFLAGS += -Wl,--gc-sections -Wl,-Map=$(BINDIR)/$(PROJECT_NAME).map,--cref,--no-warn-mismatch


vpath %.a $(PERIPH_LIB)


# startup file for MCU
STARTUP = $(SRCDIR)/startup_stm32f103xb.s

# generating of object files and dependencies
OBJS = $(addprefix $(OBJDIR)/,$(SRCS:.c=.o))
DEPS = $(addprefix $(DEPDIR)/,$(SRCS:.c=.d))


.PHONY: all library flash erase reset clean entireclean display

all: dirs library $(BINDIR)/$(TARGET) $(BINDIR)/$(PROJECT_NAME).hex $(BINDIR)/$(PROJECT_NAME).bin $(BINDIR)/$(PROJECT_NAME).lst size

library:
	make -C $(PERIPH_LIB)

dirs:
	mkdir -p $(DEPDIR) $(OBJDIR) $(BINDIR)

display:
	@echo 'SRCS = $(SRCS)'
	@echo 'OBJS = $(OBJS)'


## Compile:
# independent rule for every source file
$(OBJDIR)/main.o : $(SRCDIR)/main.c
	$(CC) $(CFLAGS) -MMD -MF $(DEPDIR)/$(*F).d -c $(SRCDIR)/main.c -o $@

$(OBJDIR)/stm32f1xx_it.o : $(SRCDIR)/stm32f1xx_it.c $(INCDIR)/stm32f1xx_it.h
	$(CC) $(CFLAGS) -MMD -MF $(DEPDIR)/$(*F).d -c $(SRCDIR)/stm32f1xx_it.c -o $@

$(OBJDIR)/system_stm32f1xx.o : $(SRCDIR)/system_stm32f1xx.c
	$(CC) $(CFLAGS) -MMD -MF $(DEPDIR)/$(*F).d -c $(SRCDIR)/system_stm32f1xx.c -o $@

$(OBJDIR)/stm32f1xx_hal_msp.o : $(SRCDIR)/stm32f1xx_hal_msp.c
	$(CC) $(CFLAGS) -MMD -MF $(DEPDIR)/$(*F).d -c $(SRCDIR)/stm32f1xx_hal_msp.c -o $@


## Link:
$(BINDIR)/$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@ $(STARTUP) -L$(PERIPH_LIB) -lstm32f1 -TSTM32F103XB_FLASH.ld

## Post-build steps:
$(BINDIR)/$(PROJECT_NAME).hex: $(BINDIR)/$(TARGET)
	$(OBJCOPY) -O ihex $(BINDIR)/$(TARGET) $@

$(BINDIR)/$(PROJECT_NAME).bin: $(BINDIR)/$(TARGET)
	$(OBJCOPY) -O binary $(BINDIR)/$(TARGET) $@

$(BINDIR)/$(PROJECT_NAME).lst: $(BINDIR)/$(TARGET)
	$(OBJDUMP) -St $(BINDIR)/$(TARGET) > $@

size: $(BINDIR)/$(TARGET)
	@echo 'size $<'
	@$(SIZE) -B $(BINDIR)/$(TARGET)
	@echo


flash2:
	openocd -f /home/erik/ARMToolchains/stm32f103c8t6.cfg -c "program $(BINDIR)/$(PROJECT_NAME).hex verify reset exit"

flash:
	st-flash write $(BINDIR)/$(PROJECT_NAME).bin 0x8000000

erase:
	openocd -f /home/erik/ARMToolchains/stm32f103c8t6.cfg -c "init" -c "reset halt" -c "stm32f1x mass_erase 0" -c "reset" -c "shutdown"

reset:
	openocd -f /home/erik/ARMToolchains/stm32f103c8t6.cfg -c "init" -c "reset" -c "shutdown"

clean:
	rm -f $(OBJDIR)/*.o $(DEPDIR)/*.d
	rm -f $(BINDIR)/$(PROJECT_NAME).elf $(BINDIR)/$(PROJECT_NAME).hex $(BINDIR)/$(PROJECT_NAME).bin $(BINDIR)/$(PROJECT_NAME).map $(BINDIR)/$(PROJECT_NAME).lst

entireclean: clean
	make -C $(PERIPH_LIB) clean
