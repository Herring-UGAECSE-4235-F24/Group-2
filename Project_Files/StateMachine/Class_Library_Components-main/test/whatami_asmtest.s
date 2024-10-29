
// assembly test file to run whatami

.global main

main:
    PUSH {LR}
    bl E4235_whatami

    @ printf
    mov r1, r0
    LDR R0, = format
    BL printf

    POP {pc}
    mov pc, lr

.data
format:
    .asciz "%d\n"
