@
@ Group 7's Assembly program to delay for a set number of milliseconds
@
@ r0 - Number of MiS to delay for
@ r1 - Number of loops per millisecond for a 1.8 GHz CPU
@

.global E4235_Delaymilli
E4235_Delaymilli:
	PUSH {R0, R1} @ Save the registers used
	@ Enter code to pull and process CPU info for loop count here
	
loop1:
	@ 900,000 is base line loops per millisecond
	ldr r1, =900000 @ Loops per millisecond, will be tuned during testing.
loop2:
	subs r1,r1,#1
	bne loop2
	subs r0, r0, #1
	bne loop1 @ Decrement count for each millisecond to delay for
	POP {R0, R1}
	bx lr
