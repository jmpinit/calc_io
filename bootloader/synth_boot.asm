 .include "m328Pdef_mod.inc"

;***** Macros
.MACRO CALL_DELAY
	ldi		r16, @0
	rcall	delay
.ENDMACRO

;***** Constants

.equ PAGESIZEB = PAGESIZE * 2	; PAGESIZEB is page size in BYTES, not words

;***** Pin definitions

.equ	PIN_ENABLE	= PC5

.equ	PIN_RING	= PB0
.equ	PIN_TIP		= PB2

.equ	PIN_RED		= PB3
.equ	PIN_GREEN	= PD6
.equ	PIN_BLUE	= PD5

.equ	PRED		= PORTB
.equ	PGREEN		= PORTD
.equ	PBLUE		= PORTD

.equ	DRED		= DDRB
.equ	DGREEN		= DDRD
.equ	DBLUE		= DDRD

;***** Register defs

.def	looplo		= r24
.def	loophi		= r25
.def	temp1		= r16
.def	temp2		= r17
.def	spmcrval	= r20

;***** Program Execution Starts Here

.cseg
.org	SECONDBOOTSTART

setup:
	; SETUP STACK
	ldi		r16, high(RAMEND)
	out		SPH, r16
	ldi		r16, low(RAMEND)
	out		SPL, r16

	; bail out of bootloader if the enable is low
	sbic	PINC, PIN_ENABLE
	jmp		0

	; SETUP DEBUG LED
	sbi		DRED,	PIN_RED
	sbi		DGREEN,	PIN_GREEN
	sbi		DBLUE,	PIN_BLUE

	; TURN ON BLUE LED
	sbi		PBLUE, PIN_BLUE

	; RESET CALC CONNECTION
	rcall	ring_set_high
	rcall	tip_set_high

	; RESET PAGE PTR
	clr		ZL
	clr		ZH

reset_buffer:
	ldi		XH, high(SRAM_START)
	ldi		XL, low(SRAM_START)

loading:
	; check if calc is talking to us
	in		r18, PINB
	andi	r18, (1<<PIN_RING)|(1<<PIN_TIP)
	cpi		r18, (1<<PIN_RING)|(1<<PIN_TIP)
	breq	loading			; no message - keep listening

	rcall	calc_receive	; get the calculator msg

	; put data into buffer
	st		X+, r16

	; check if buffer is full
	cpi		XH, high(SRAM_START + PAGESIZEB)
	brne	loading
	cpi		XL, low(SRAM_START + PAGESIZEB)
	brne	loading

	; buffer is full - do a page write
	ldi		YH, high(SRAM_START)
	ldi		YL, low(SRAM_START)
	rcall	Write_page

	rjmp	reset_buffer

done:
	; green light means bootloader successful/done
	cbi		PBLUE, PIN_BLUE
	sbi		PGREEN, PIN_GREEN

	; start the loaded program
	jmp		0

.include	"lib_calc.asm"

Write_page:
	; Page Erase
	ldi spmcrval, (1<<PGERS) | (1<<SELFPRGEN)
	call Do_spm
	; re-enable the RWW section
	ldi spmcrval, (1<<RWWSRE) | (1<<SELFPRGEN)
	call Do_spm
	; transfer data from RAM to Flash page buffer
	ldi looplo, low(PAGESIZEB) ;init loop variable
	ldi loophi, high(PAGESIZEB) ;not required for PAGESIZEB<=256

Error:
	; we failed for some reason
	; turn on the red light of failure
	cbi		PBLUE, PIN_BLUE
	cbi		PGREEN, PIN_GREEN
	sbi		PRED, PIN_RED

	; and sulk forever
	rjmp	Error

Wrloop:
	ld r0, Y+
	ld r1, Y+
	ldi spmcrval, (1<<SELFPRGEN)
	call Do_spm
	adiw ZH:ZL, 2
	sbiw loophi:looplo, 2 ;use subi for PAGESIZEB<=256
	brne Wrloop
	; execute Page Write
	subi ZL, low(PAGESIZEB) ;restore pointer
	sbci ZH, high(PAGESIZEB) ;not required for PAGESIZEB<=256
	ldi spmcrval, (1<<PGWRT) | (1<<SELFPRGEN)
	call Do_spm
	; re-enable the RWW section
	ldi spmcrval, (1<<RWWSRE) | (1<<SELFPRGEN)
	call Do_spm
	; read back and check, optional
	ldi looplo, low(PAGESIZEB) ;init loop variable
	ldi loophi, high(PAGESIZEB) ;not required for PAGESIZEB<=256
	subi YL, low(PAGESIZEB) ;restore pointer
	sbci YH, high(PAGESIZEB)

Rdloop:
	lpm r0, Z+
	ld r1, Y+
	cpse r0, r1
	jmp Error
	sbiw loophi:looplo, 1 ;use subi for PAGESIZEB<=256
	brne Rdloop
	; return to RWW section
	; verify that RWW section is safe to read
	Return:
	in temp1, SPMCSR
	sbrs temp1, RWWSB ; If RWWSB is set, the RWW section is not ready yet
	ret
	; re-enable the RWW section
	ldi spmcrval, (1<<RWWSRE) | (1<<SELFPRGEN)
	call Do_spm
	rjmp Return

Do_spm:
; check for previous SPM complete
Wait_spm:
	in temp1, SPMCSR
	sbrc temp1, SELFPRGEN
	rjmp Wait_spm
	; input: spmcrval determines SPM action
	; disable interrupts if enabled, store status
	in temp2, SREG
	cli

; check that no EEPROM write access is present
Wait_ee:
	sbic EECR, EEPE
	rjmp Wait_ee
	; SPM timed sequence
	out SPMCSR, spmcrval
	spm
	; restore SREG (to enable interrupts if originally enabled)
	out SREG, temp2
	ret

