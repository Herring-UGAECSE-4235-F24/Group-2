
.section .text
.global exponential

exponential:
	// input for x comes in s0
	// input for n comes in r0
	push {lr}
	mov r5, r0
	vmov.f32 s2, s0
	sub r5, #1

loop:
	vmul.f32 s0, s0, s2
	subs r5, #1
	bne loop

end:
	pop {lr}
	bx lr        
