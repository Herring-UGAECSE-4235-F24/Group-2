.include "../src/E4235_WhatAmI.s"

    .text
    .global main

main:
    bl E4235_WhatAmI    @ calls WhatAmI to get frequency
    mov r1, r0          @ moves frequency into second argument
    ldr r0, =output     @ moves output into first argument
    bl printf           @ prints to terminal
    mov r7, #1
    svc 0

    .data
output:
    .asciz "frequency: %d\n"
