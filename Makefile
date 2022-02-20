CROSS_COMPILE:=arm-linux-gnueabihf-
AS:=$(CROSS_COMPILE)as
CC:=$(CROSS_COMPILE)gcc
STRIP:=$(CROSS_COMPILE)strip

.PHONY:
all: AppMain.bin m4_loader.bin

.PHONY:
clean:
	@rm -f *.bin *.elf pixels.c

pixels.c:
	@python3 img2c.py image.jpg pixels.c

AppMain.bin: pixels.c
	@$(CC) -nostdlib -static -fPIC -mcpu=cortex-a7 main.S pixels.c -o main.elf
	@./extract.py -p main.elf AppMain.bin

m4_loader.bin:
	@$(AS) m4_loader.S -mcpu=cortex-m4 -o m4_loader.elf
	@./extract.py -p m4_loader.elf m4_loader.bin
