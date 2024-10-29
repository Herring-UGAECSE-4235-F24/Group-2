@
@ Group 7's Assembly program to delay for a set number of nanoseconds
@
@ r0 - Number of NS to delay for
@ r1 - Number of loops per nanosecond for a 1.8 GHz CPU
@

.global E4235_Delaynano
E4235_Delaynano:
	PUSH {R0, R1} @ Save the registers used
	@ Enter code to pull and process CPU info for loop count here

@ NOTE: AS WRITTEN, THE LOOP COUNT REQUIRED TO DELAY FOR 1 NS IS .9 DELAY LOOPS. NEED TO FIGURE OUT
@ AN ALTERNATE SOLUTION, OR TELL HERRING WE CAN'T DO IT. MAYBE ROUND UP TO 1 LOOP? IDK
loop1:
	@ 9,000,000 is base line loops per nanosecond
	ldr r1, =1 @ .9 Loops per nanosecond for a 1.8 GHz CPU, rounded up to 1
loop2:
	subs r1,r1,#1
	bne loop2
	subs r0, r0, #1
	bne loop1 @ Decrement count for each nanosecond to delay for
	POP {R0, R1}
	bx lr
