
    .text
    .global E4235_KYBdeblock

E4235_KYBdeblock:
    push {lr}
    push {r1-r2}

    cmp r0, #0      @ deblocking
    beq Off
    cmp r0, #1      @ blocking
    beq On

OutOfRange:
    mov r0, #1      @ input out of range
    b exit

On:
    mov r0, #0 	    @ file descriptor for stdin
	mov r1, #3	    @ get F_GETFL
	bl fcntl
	mov r2, #2048	@ set O_NONBLOCK
	orr r1, r1, r2	@ combine flags
	mov r2, r1
	mov r0, #0	    @ file descriptor for stdin
	mov r1, #4	    @ set F_SETFL
    bl fcntl
    mov r0, #0	    @ successful execution
	b exit

Off:
    mov r0, #0 	    @ file descriptor for stdin
	mov r1, #3	    @ get F_GETFL
	bl fcntl
	mvn r2, #2048	@ set inverse O_NONBLOCK
	and r1, r1, r2	@ combine flags
	mov r2, r1
	mov r0, #0	    @ file descriptor for stdin
	mov r1, #4	    @ set F_SETFL
    bl fcntl
    mov r0, #0	    @ successful execution
	b exit

exit:
    pop {r1-r2}
    pop {lr}
    bx lr
