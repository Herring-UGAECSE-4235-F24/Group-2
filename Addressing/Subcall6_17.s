@Let's investigate calling a function.
@Deliverable 1: Run the program.  What are the values of R0, R1, and R2: Prior to calling myfunc; after executing the modify part of myfunc; returning from myfunc.	
@Deliverable 2: Rewrite the program using push and pop.  Only use one line for each to do this.  Show your program.  Show that your results are the same as before
@ prior to myfunc; after modify; return from myfunc.



	.text
	.global main
main:
	ldr  	r0, =0x125		@ r0 = 0x125
	ldr  	r1, =0x144		@ r1 = 0x144
	mov  	r2, #0x56		@ r2 = 0x56
	bl	myFunc			@ call a subroutine
	add	r3, r0, r1		@ r3 = r0 + r1 = 0x125 + 0x144 = 0x269
	add	r3, r3, r2		@ r3 = r3 + r2 = 0x269 + 0x56 = 0x2bf

	mov	r7, #1
	svc	0
	
myFunc:
	@ save r0, r1, and r2 on stack before they are used 
	push {r0-r2}
	@ -------- modify r0, r1, and r2 
	mov  	r0, #0	@ r0 = 0
	mov  	r1, #0	@ r1 = 0
	mov  	r2, #0	@ r2 = 0
	@ --------

	@ restore the original registers contents from stack
	pop {r0-r2}

	bx	lr		 @ return to caller
