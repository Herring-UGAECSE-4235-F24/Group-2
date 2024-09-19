@ storing data in program memory.
@ We will look at the program from the lectures and investigate how the compiler/assembler stores the defined data into memory.
@ Deliverable 1: Run the program.  What value is stored into R0?
@ use gdb disas to display the dissasembly and gdb x/12xw _start to display 10 words of memory.  
@ Deliverable 2: Make a table with the addresses representing 4 byte rows and provide the value at each byte.
@ Example:	00004000	87	65	43	21
@ In the example: byte 4000 contains 21, byte 4001 contains 43, byte 4002 contains 65, byte 4003 contains 87 the full word is: 0x87654321
@ The next address row would be 00004004.  Have your table count down by addresses so the top row is lowest address.


	.text
	.global main
main:
_foo:
	ldr	r2, =our_fixed_data	@ point to our_fixed_data	

	ldrb	r0, [r2]  @ load r0 with the contents of memory pointed to by r2
_test:
	@ terminate the program
	mov	r7, #1			
	svc	0
	
our_fixed_data:    					
	.byte	0x55, 0x33, 1, 2, 3, 4, 5, 6		
	.word	0x23222120, 0x30		
	.hword	0x4540, 0x50			
