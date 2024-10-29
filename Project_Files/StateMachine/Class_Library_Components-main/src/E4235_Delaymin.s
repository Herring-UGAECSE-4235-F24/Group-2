@
@ Group 7's Assembly program to delay for a set number of minutes
@
@ r0 - Number of Min to delay for
@ r1 - Number of loops per second for a 1.8 GHz CPU
@ r2 - Number of Seconds in a minute
@

.global E4235_Delaymin
E4235_Delaymin:
	PUSH {R0, R1} @ Save the registers used
	@ Enter code to pull and process CPU info for loop count here
	
loop1:
	ldr r2, =60
loop2:
	@ 900,000,000 is base line loops per second
	ldr r1, =900000000 @ Loops per second, will be tuned during testing.
loop3:
	subs r1,r1,#1
	bne loop3
	subs r2, r2, #1
	bne loop2 @ Decrement second count by 1
	subs r0, r0, #1
	bne loop1 @ Decrement minute count by 1
	POP {R0, R1}
	bx lr
