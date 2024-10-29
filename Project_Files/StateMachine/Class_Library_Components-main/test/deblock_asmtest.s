.text
.global main

main:

    ldr r0, = inputform
    ldr r1, =input
    bl scanf
    ldr r1, =input

    ldr r1, [r1]

    mov r0, r1
    mov r0, #2
    bl deblock

    mov r0, #1 @Std Out
    ldr r1, =output
    mov r2, #5 @length of out string
    mov r7, #4 @write sys call
    svc 0

    b main

.data
output: .ascii "xxxx\n"
inputform:
        .asciz "%d"
input:
        .word 0

