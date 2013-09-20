all:
	~/.wine/drive_c/Program\ Files/Atmel/AVR\ Tools/AvrAssembler2/avrasm2.exe -fI synth_boot.asm 

avra:
	avra synth_boot.asm

program:
	sudo avrdude -c usbtiny -p atmega328p -U flash:w:synth_boot.hex
