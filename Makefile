CROSS_COMPILE:=arm-linux-gnueabihf-
AS:=$(CROSS_COMPILE)as
CC:=$(CROSS_COMPILE)gcc
STRIP:=$(CROSS_COMPILE)strip

.PHONY:
all: AppMain.bin

.PHONY:
clean:
	@rm -f *.bin *.elf

AppMain.bin:
	@$(AS) main.S -o main.elf
	@./extract.py -p main.elf AppMain.bin
