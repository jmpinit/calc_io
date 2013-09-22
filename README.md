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

## AVR

* avrasm2.exe from Atmel AVR Studio 4 (for Windows, but works fine on Linux via Wine)

## TI Calc

__To compile:__

* tasm - _see intro of [Learn TI-83 Plus Assembly in 28 Days](http://www.ticalc.org/archives/files/fileinfo/268/26877.html)_
* devpac8x - _see intro of [Learn TI-83 Plus Assembly in 28 Days](http://www.ticalc.org/archives/files/fileinfo/268/26877.html)_

__To emulate on computer:__

* [tilem2](http://lpg.ticalc.org/prj_tilem/download.html) 

Compilation
===========

_Proper explanation coming soon..._ For now just hit `make <the thing you'd like to make>` and it'll probably work.
Check out the makefiles.

Installation
============

_Coming soon..._
