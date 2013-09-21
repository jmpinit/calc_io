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

