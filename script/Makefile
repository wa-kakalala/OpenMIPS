ifndef CROSS_COMPILE
CROSS_COMPILE = mips-sde-elf-
endif
CC = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump

OBJECTS = inst_rom.o

export CROSS_COMPILE

# rules of compliation
all: inst_rom.dat

%.o: %.s
	$(CC) -mips32 $< -o $@

inst_rom.om: ram.ld $(OBJECTS)
	$(LD) -T ram.ld $(OBJECTS) -o $@
inst_rom.bin : inst_rom.om
	$(OBJCOPY) -O binary $< $@
inst_rom.dat : inst_rom.bin
	./bin2mem -f $< -o $@
asm: inst_rom.om
	mips-sde-elf-objdump -D $< > inst_rom.asm
clean:
	rm -rf *.o *.om *.bin *.dat
