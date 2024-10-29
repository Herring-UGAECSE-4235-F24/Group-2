@ Changes terminal from blocking to non-blocking and vice versa
@
@ int deblock(int)
@ 
@ input:
@   R0 - integer dentoing blocking or non-blocking
@           0 = blocking
@           1 = non-blocking
@
@ output:
@   R0 - validity (comes from fcntl)
@           -1 = invalid

.text
.global deblock

deblock:
        push {r1 - r7,lr}
        mov r4, r0

        mov r0, #0      @Std input
        mov r1, #3      @get F_GETFL
        bl fcntl
        mov r2, #2048   @2048 = NON_BLOCKING constant in fcnt
        mov r0, #-1     @ will output if invalid input

        cmp r4, #0
        beq blocking
        cmp r4, #1
        beq nonblocking
        bne _skip
nonblocking:
        orr r1, r1, r2  @combine flags
        b changeflg
blocking:
        add r2, r2, #1 // ~NON-BLOCKING = -2049
        neg r2, r2
        and r1, r1, r2 //combine flags
changeflg:
        mov r2, r1
        mov r0, #0      @Std input
        mov r1, #4      @set F_SETFL
        bl fcntl
_skip:
        pop {r1 - r7, lr}
        bx lr

