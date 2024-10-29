
    .include "../src/E4235_PWM.s"

    .text
    .global main

main:
    mov r0, #1
    mov r1, #1000
    mov r2, #50

    bl E4235_PWM
