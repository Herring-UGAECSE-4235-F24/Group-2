@
@ Group 7's Assembly program to delay for a set number of microseconds
@
@ r0 - Number of McS to delay for
@ r1 - Number of loops per microsecond for a 1.8 GHz CPU
@

.global E4235_Delaymicro
E4235_Delaymicro:
	PUSH {R0, R1} @ Save the registers used
	@ Enter code to pull and process CPU info for loop count here
	
loop1:
	@ 900 is base line loops per microsecond
	ldr r1, =900 @ Loops per microsecond, will be tuned during testing.
loop2:
	subs r1,r1,#1
	bne loop2
	subs r0, r0, #1
	bne loop1 @ Decrement count for each microsecond to delay for
	POP {R0, R1}
	bx lr
