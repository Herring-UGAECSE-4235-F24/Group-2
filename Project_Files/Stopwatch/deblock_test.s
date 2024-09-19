    .text
    .global main
    .include "./deblock.s"

main:

@ read from stdin
read:
	mov r0, #0	@ file descriptor for stdin
	mov r2, #4	@ allocates bytes to read
	mov r7, #3	@ svc read
	ldr r1, =input
	str r0, [r1]	@ reset input
	svc 0
	ldrb r1, [r1]	@ read byte in input
	b    check

@ check input against ascii characters
check:
	cmp r1, #'b'    @ blocking
	beq block
	cmp r1, #'d'    @ deblocking
	beq deblock
	cmp r1, #'q'    @ quit
	beq quit
	b   print

@ change the terminal to blocking
block:
    mov r0, #0
    bl  E4235_KYBdeblock
    b   read

@ change the terminal to nonblocking
deblock:
    mov r0, #1
    bl  E4235_KYBdeblock
    b   read

@ print a string to the terminal
print:
    ldr r0, =string
    bl  printf
    ldr r1, =input
    b   read

@ quit the program
quit:
    mov r7, #1
    svc 0

    .data
string:
    .asciz "hello there general kenobi\n"

input:
    .asciz "%c"
