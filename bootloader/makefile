all:
	~/.wine/drive_c/Program\ Files/Atmel/AVR\ Tools/AvrAssembler2/avrasm2.exe -fI synth_boot.asm 

avra:
	avra synth_boot.asm

program:
	sudo avrdude -c usbtiny -p atmega328p -U flash:w:synth_boot.hex

fuses:
	sudo avrdude -c usbtiny -p atmega328p -U lfuse:w:0xe2:m -U hfuse:w:0xdc:m -U efuse:w:0xff:m
