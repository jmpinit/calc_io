 .include "m328Pdef_mod.inc"

;***** Macros
.MACRO CALL_DELAY
	ldi		r16, @0
	rcall	delay
.ENDMACRO

;***** Pin definitions

.equ	PIN_RING	= PB0
.equ	PIN_TIP		= PB2

.equ	PIN_SND		= PB1

.equ	PIN_RED		= PB3
.equ	PIN_GREEN	= PD6
.equ	PIN_BLUE	= PD5

.cseg
.org 0
	rjmp	reset

;INPUT: r16 time
;DESTROYS: r0, r1, r2
delay:
	clr		r0
	clr		r1
delay0: 
	dec		r0
	brne	delay0
	dec		r1
	brne	delay0
	dec		r16
	brne	delay0
	ret

;***** Program Execution Starts Here

reset:
	; SETUP STACK
	ldi		r16, low(RAMEND)
	out		SPL, r16

	; SETUP DEBUG LED
	sbi		DDRB, PIN_RED

forever:
	sbi		PORTB, PIN_RED
	CALL_DELAY 15
	cbi		PORTB, PIN_RED
	CALL_DELAY 15

	rjmp	forever
