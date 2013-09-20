all:
	avra calc_synth.asm

program:
	sudo avrdude -c usbtiny -p atmega328p -U flash:w:calc_synth.hex
