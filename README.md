TI-83+ with Atmega328P Symbiote
===============================

![sinewave output](http://hackniac.com/images/calc_out/sine_out_sm.jpg)

Turn your calculator into a...
------------------------------

* Rad audio synth
* Really slow oscilloscope
* Really slow logic analyzer
* Multimeter
* [Bus pirate](http://dangerousprototypes.com/docs/Bus_Pirate)

AVR Development on Calculator
-----------------------------

* Write and compile AVR assembly code
* Flash AVR directly from calculator using TI Link Protocol AVR bootloader and a program on the calculator.

Dependencies
============

* avrasm2.exe from Atmel AVR Studio 4 (for Windows, but works on Linux via Wine)

Compilation
===========

__synthesizer:__ `make synthesizer`

__bootloader:__ `make bootloader` 

_check out src/makefile for the full list of targets_
