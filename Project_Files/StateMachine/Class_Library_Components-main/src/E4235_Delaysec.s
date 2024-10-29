@
@ Group 7's Assembly program to delay for a set number of seconds
@
@ r0 - Number of Sec to delay for
@ r1 - Number of loops per centisecond for a 1.8 GHz CPU
@

.global E4235_Delaysec
E4235_Delaysec:
	PUSH {R0, R1} @ Save the registers used
	@ Enter code to pull and process CPU info for loop count here
	
loop1:
	@ 900,000,000 is base line loops per second
	ldr r1, =900000000 @ Loops per second, will be tuned during testing.
loop2:
	subs r1,r1,#1
	bne loop2
	subs r0, r0, #1
	bne loop1 @ Decrement count for each second to delay for
	POP {R0, R1}
	bx lr
