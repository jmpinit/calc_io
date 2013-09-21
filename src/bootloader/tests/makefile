PROG := blink

all:
	~/.wine/drive_c/Program\ Files/Atmel/AVR\ Tools/AvrAssembler2/avrasm2.exe -fI $(PROG).asm

avra:
	avra $(PROG).asm

program:
	sudo avrdude -c usbtiny -p atmega328p -U flash:w:$(PROG).hex

fuses:
	sudo avrdude -c usbtiny -p atmega328p -U lfuse:w:0xe2:m -U hfuse:w:0xdc:m -U efuse:w:0xff:m
