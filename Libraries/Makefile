

CC = arm-none-eabi-gcc
AR = arm-none-eabi-ar


vpath %.c STM32F1xx_HAL_Driver/Src

CFLAGS  = -Os
CFLAGS += -mlittle-endian -mthumb -mcpu=cortex-m3
CFLAGS += -ffreestanding -nostdlib
CFLAGS += -ffunction-sections
CFLAGS += -ICMSIS/Include 
CFLAGS += -ICMSIS/ST/Include 
CFLAGS += -ISTM32F1xx_HAL_Driver/Inc
CFLAGS += -I../inc

LIBAR = libstm32f1.a


# ***  List of files, that should be compiled ***
# You can obtain it as a list of files in dir ./STM32F0xx_HAL_Driver/Src
# That directory don't contain all possible HAL drivers, only those used by STMCube (depends on peripherals used in STMCube project).
# It's easy to add another driver files, only add them into directories ./STM32F0xx_HAL_Driver/Src and ./STM32F0xx_HAL_Driver/Inc and to this list.

SRCS  = stm32f1xx_hal.c \
	stm32f1xx_hal_cortex.c \
        stm32f1xx_hal_dma.c \
        stm32f1xx_hal_flash.c \
        stm32f1xx_hal_flash_ex.c \
        stm32f1xx_hal_gpio.c \
        stm32f1xx_hal_i2c.c \
        stm32f1xx_hal_pwr.c \
        stm32f1xx_hal_rcc.c \
        stm32f1xx_hal_rcc_ex.c \
        stm32f1xx_hal_tim.c \
        stm32f1xx_hal_tim_ex.c
#        stm32f1xx_hal_i2c_ex.c \
#        stm32f1xx_hal_pwr_ex.c \

OBJS = $(addprefix obj/,$(SRCS:.c=.o))
DEPS = $(addprefix dep/,$(SRCS:.c=.d))

.PHONY: all clean


# First create directories, than compile files
all: dirs $(LIBAR)

-include $(DEPS)

dirs:
	mkdir -p dep obj


# Compilation of individual files
obj/%.o : %.c
	@echo "Processing: " $<
	$(CC) $(CFLAGS) -c -o $@ $< -MMD -MF dep/$(*F).d


# Will create archive with libraries
$(LIBAR): $(OBJS)
	$(AR) -r $@ $(OBJS)

clean:
	rm -f $(OBJS) $(DEPS) $(LIBAR)

