@Let's examine how the compiler changes the psuedo instruction, LDR, so that it can compile and run on our processor.
@Deliverable 1: Using GDB disassemble (gdb disas) and GDB display memory (gdb x/28b _start) , show the result and describe the instructions and how they execute.

	.text
	.global main
main:
	ldr	r0, =0x12345678
	ldr	r1, =0x86427531
	add	r2, r0, r1
	mov	r7,#1
	svc 0
