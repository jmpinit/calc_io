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
.org OC2Aaddr
	rjmp	sound_isr

;***** SOUND INTERRUPT
sound_isr:
	push	r16
	in		r16, SREG
	push	r16
	
	lpm		r16, Z+
	sts		OCR1AL, r16

	cpi		ZL, low((wave_sin + 128) << 1)
	brne	sound_isr_skip
	cpi		ZH, high((wave_sin + 128) << 1)
	brne	sound_isr_skip

	ldi		ZL, low(wave_sin << 1)
	ldi		ZH, high(wave_sin << 1)
sound_isr_skip:

	ldi		r16, 6
	sts		TCNT2, r16

	pop		r16
	out		SREG, r16
	pop		r16

	reti

;***** RING CONTROL
ring_set_high:
	cbi		DDRB, PIN_RING
	sbi		PORTB, PIN_RING
	ret

ring_set_low:
	cbi		PORTB, PIN_RING
	sbi		DDRB, PIN_RING
	ret

ring_wait_high:
	sbis	PINB, PIN_RING
	rjmp	ring_wait_high
	ret

ring_wait_low:
	sbic	PINB, PIN_RING
	rjmp	ring_wait_low
	ret

;**** TIP CONTROL
tip_set_high:
	cbi		DDRB, PIN_TIP
	sbi		PORTB, PIN_TIP
	ret

tip_set_low:
	cbi		PORTB, PIN_TIP
	sbi		DDRB, PIN_TIP
	ret

tip_wait_high:
	sbis	PINB, PIN_TIP
	rjmp	tip_wait_high
	ret

tip_wait_low:
	sbic	PINB, PIN_TIP
	rjmp	tip_wait_low
	ret

;**** CALC RECEIVE
;OUTPUT: r16 data
calc_receive:
	ldi		r17, 8

calc_receive_wait:
	in		r18, PINB
	andi	r18, (1<<PIN_RING)|(1<<PIN_TIP)
	cpi		r18, (1<<PIN_RING)|(1<<PIN_TIP)
	breq	calc_receive_wait

calc_receive_fork:
	sbis	PINB, PIN_TIP
	rjmp	calc_receive_zero
calc_receive_one:
	sec
	ror		r16

	rcall	short_delay

	rcall	tip_set_low
	rcall	ring_wait_high
	rcall	tip_set_high

	rjmp	calc_receive_repeat
calc_receive_zero:
	clc
	ror		r16

	rcall	short_delay

	rcall	ring_set_low
	rcall	tip_wait_high
	rcall	ring_set_high
calc_receive_repeat:
	dec		r17
	brne	calc_receive_wait
	
	rcall	ring_set_high
	rcall	tip_set_high

	ret

;**** CALC SEND
;INPUT: r16 byte to send
calc_send:
	ldi		r17, 8

	lsr		r16
calc_send_fork:
	brcc	calc_send_zero
calc_send_one:
	rcall	ring_set_low
	rcall	short_delay
	rcall	tip_wait_low
	rcall	short_delay
	rcall	ring_set_high
	rcall	short_delay
	rcall	tip_wait_high
	rcall	short_delay

	rjmp	calc_send_repeat
calc_send_zero:
	rcall	tip_set_low
	rcall	short_delay
	rcall	ring_wait_low
	rcall	short_delay
	rcall	tip_set_high
	rcall	short_delay
	rcall	ring_wait_high
	rcall	short_delay
	
calc_send_repeat:
	lsr		r16
	
	dec		r17
	brne	calc_send_fork
	
	rcall	ring_set_high
	rcall	tip_set_high

	ret

;**** SHORT DELAY
.equ b = 3;

short_delay:
	ldi	r18,b			;1

short_delay1:
	dec		r18			;1
	nop					;1
	nop					;1
	nop					;1
	nop					;1
	nop					;1
	brne 	short_delay1	;1 or 2
	ret					;4      

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

	; SETUP PIN DIRECTIONS
	ldi		r16, 0b00000111
	out		DDRC, r16
	out		PORTC, r16

	; SETUP DEBUG LED
	sbi		DDRB, PIN_RED
	sbi		DDRD, PIN_GREEN
	sbi		DDRD, PIN_BLUE
	sbi		PORTB, PIN_RED

	; SETUP PWM FOR SOUND
	sbi		DDRB, PIN_SND		; SND pin output

	lds		r16, TCCR1A
	ori		r16, (1<<COM1A1)|(1<<WGM10)
	sts		TCCR1A, r16

	ldi		r16, (1<<CS10)|(1<<WGM12)
	sts		TCCR1B, r16

	; TIMER INTERRUPT FOR SOUND
	ldi		r16, 0
	sts		TCCR2A, r16

	ldi		r16, 1<<CS20
	sts		TCCR2B, r16

	ldi		r16, 1<<OCIE2A
	sts		TIMSK2, r16

	ldi		r16, 32
	sts		OCR2A, r16

	; wave_noise SAMPLES
	ldi		ZL, low(wave_sin << 1)
	ldi		ZH, high(wave_sin << 1)

	; RESET CALC CONNECTION
	rcall	ring_set_high
	rcall	tip_set_high

	sei

forever:
	; check if calc is talking to us
	in		r18, PINB
	andi	r18, (1<<PIN_RING)|(1<<PIN_TIP)
	cpi		r18, (1<<PIN_RING)|(1<<PIN_TIP)
	breq	forever			; no message - keep listening

	rcall	calc_receive	; get the calculator msg

	sts		OCR2A, r16

	cbi		PORTB, PIN_RED
	sbi		PORTD, PIN_GREEN

	rjmp	forever			; buffer empty

wave_noise:
.db 231, 184 ;0
.db 129, 165 ;1
.db 208, 204 ;2
.db 195, 9 ;3
.db 50, 224 ;4
.db 9, 244 ;5
.db 14, 194 ;6
.db 63, 217 ;7
.db 20, 75 ;8
.db 46, 30 ;9
.db 75, 160 ;10
.db 20, 202 ;11
.db 26, 162 ;12
.db 165, 103 ;13
.db 233, 120 ;14
.db 191, 19 ;15
.db 207, 199 ;16
.db 23, 241 ;17
.db 199, 161 ;18
.db 112, 46 ;19
.db 1, 21 ;20
.db 254, 210 ;21
.db 217, 232 ;22
.db 111, 30 ;23
.db 131, 142 ;24
.db 42, 236 ;25
.db 8, 126 ;26
.db 245, 69 ;27
.db 134, 207 ;28
.db 54, 115 ;29
.db 56, 161 ;30
.db 137, 192 ;31
.db 242, 168 ;32
.db 101, 225 ;33
.db 154, 132 ;34
.db 34, 156 ;35
.db 198, 190 ;36
.db 208, 29 ;37
.db 131, 1 ;38
.db 9, 7 ;39
.db 18, 194 ;40
.db 74, 100 ;41
.db 37, 90 ;42
.db 188, 69 ;43
.db 122, 157 ;44
.db 52, 109 ;45
.db 176, 103 ;46
.db 149, 67 ;47
.db 12, 9 ;48
.db 97, 7 ;49
.db 27, 24 ;50
.db 101, 94 ;51
.db 219, 149 ;52
.db 218, 240 ;53
.db 186, 211 ;54
.db 221, 54 ;55
.db 152, 83 ;56
.db 152, 123 ;57
.db 252, 234 ;58
.db 130, 41 ;59
.db 69, 216 ;60
.db 13, 125 ;61
.db 22, 137 ;62
.db 140, 17 ;63
.db 176, 223 ;64
.db 164, 124 ;65
.db 92, 96 ;66
.db 176, 164 ;67
.db 215, 205 ;68
.db 162, 206 ;69
.db 52, 248 ;70
.db 109, 184 ;71
.db 105, 157 ;72
.db 236, 220 ;73
.db 60, 236 ;74
.db 159, 224 ;75
.db 20, 144 ;76
.db 1, 121 ;77
.db 51, 216 ;78
.db 84, 109 ;79
.db 10, 66 ;80
.db 134, 168 ;81
.db 120, 193 ;82
.db 216, 239 ;83
.db 244, 224 ;84
.db 37, 91 ;85
.db 217, 65 ;86
.db 84, 213 ;87
.db 51, 205 ;88
.db 143, 171 ;89
.db 89, 92 ;90
.db 178, 110 ;91
.db 40, 207 ;92
.db 235, 171 ;93
.db 143, 84 ;94
.db 43, 223 ;95
.db 159, 89 ;96
.db 228, 228 ;97
.db 221, 234 ;98
.db 142, 41 ;99
.db 21, 79 ;100
.db 253, 86 ;101
.db 165, 75 ;102
.db 145, 164 ;103
.db 128, 187 ;104
.db 225, 112 ;105
.db 85, 153 ;106
.db 3, 183 ;107
.db 64, 182 ;108
.db 63, 43 ;109
.db 149, 192 ;110
.db 194, 195 ;111
.db 93, 86 ;112
.db 46, 13 ;113
.db 25, 228 ;114
.db 162, 89 ;115
.db 79, 221 ;116
.db 170, 160 ;117
.db 171, 235 ;118
.db 102, 175 ;119
.db 14, 240 ;120
.db 108, 254 ;121
.db 182, 134 ;122
.db 8, 234 ;123
.db 192, 213 ;124
.db 236, 151 ;125
.db 76, 1 ;126
.db 4, 16 ;127

wave_sin:
.db 128, 131 ;0
.db 134, 137 ;1
.db 140, 143 ;2
.db 146, 149 ;3
.db 152, 156 ;4
.db 159, 162 ;5
.db 165, 168 ;6
.db 171, 174 ;7
.db 176, 179 ;8
.db 182, 185 ;9
.db 188, 191 ;10
.db 193, 196 ;11
.db 199, 201 ;12
.db 204, 206 ;13
.db 209, 211 ;14
.db 213, 216 ;15
.db 218, 220 ;16
.db 222, 224 ;17
.db 226, 228 ;18
.db 230, 232 ;19
.db 234, 236 ;20
.db 237, 239 ;21
.db 240, 242 ;22
.db 243, 245 ;23
.db 246, 247 ;24
.db 248, 249 ;25
.db 250, 251 ;26
.db 252, 252 ;27
.db 253, 254 ;28
.db 254, 255 ;29
.db 255, 255 ;30
.db 255, 255 ;31
.db 255, 255 ;32
.db 255, 255 ;33
.db 255, 255 ;34
.db 254, 254 ;35
.db 253, 252 ;36
.db 252, 251 ;37
.db 250, 249 ;38
.db 248, 247 ;39
.db 246, 245 ;40
.db 243, 242 ;41
.db 240, 239 ;42
.db 237, 236 ;43
.db 234, 232 ;44
.db 230, 228 ;45
.db 226, 224 ;46
.db 222, 220 ;47
.db 218, 216 ;48
.db 213, 211 ;49
.db 209, 206 ;50
.db 204, 201 ;51
.db 199, 196 ;52
.db 193, 191 ;53
.db 188, 185 ;54
.db 182, 179 ;55
.db 176, 174 ;56
.db 171, 168 ;57
.db 165, 162 ;58
.db 159, 156 ;59
.db 152, 149 ;60
.db 146, 143 ;61
.db 140, 137 ;62
.db 134, 131 ;63
.db 128, 124 ;64
.db 121, 118 ;65
.db 115, 112 ;66
.db 109, 106 ;67
.db 103, 99 ;68
.db 96, 93 ;69
.db 90, 87 ;70
.db 84, 81 ;71
.db 79, 76 ;72
.db 73, 70 ;73
.db 67, 64 ;74
.db 62, 59 ;75
.db 56, 54 ;76
.db 51, 49 ;77
.db 46, 44 ;78
.db 42, 39 ;79
.db 37, 35 ;80
.db 33, 31 ;81
.db 29, 27 ;82
.db 25, 23 ;83
.db 21, 19 ;84
.db 18, 16 ;85
.db 15, 13 ;86
.db 12, 10 ;87
.db 9, 8 ;88
.db 7, 6 ;89
.db 5, 4 ;90
.db 3, 3 ;91
.db 2, 1 ;92
.db 1, 0 ;93
.db 0, 0 ;94
.db 0, 0 ;95
.db 0, 0 ;96
.db 0, 0 ;97
.db 0, 0 ;98
.db 1, 1 ;99
.db 2, 3 ;100
.db 3, 4 ;101
.db 5, 6 ;102
.db 7, 8 ;103
.db 9, 10 ;104
.db 12, 13 ;105
.db 15, 16 ;106
.db 18, 19 ;107
.db 21, 23 ;108
.db 25, 27 ;109
.db 29, 31 ;110
.db 33, 35 ;111
.db 37, 39 ;112
.db 42, 44 ;113
.db 46, 49 ;114
.db 51, 54 ;115
.db 56, 59 ;116
.db 62, 64 ;117
.db 67, 70 ;118
.db 73, 76 ;119
.db 79, 81 ;120
.db 84, 87 ;121
.db 90, 93 ;122
.db 96, 99 ;123
.db 103, 106 ;124
.db 109, 112 ;125
.db 115, 118 ;126
.db 121, 124 ;127
