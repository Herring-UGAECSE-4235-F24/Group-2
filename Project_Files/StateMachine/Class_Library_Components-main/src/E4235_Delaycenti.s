@
@ Group 7's Assembly program to delay for a set number of centiseconds
@
@ r0 - Number of CS to delay for
@ r1 - Number of loops per centisecond for a 1.8 GHz CPU
@

.global E4235_Delaycenti
E4235_Delaycenti:
	PUSH {R0, R1} @ Save the registers used
	@ Enter code to pull and process CPU info for loop count here
	
loop1:
	@ 9,000,000 is base line loops per centisecond
	ldr r1, =9000000 @ Loops per centisecond, will be tuned during testing.
loop2:
	subs r1,r1,#1
	bne loop2
	subs r0, r0, #1
	bne loop1 @ Decrement count for each centisecond to delay for
	POP {R0, R1}
	bx lr
