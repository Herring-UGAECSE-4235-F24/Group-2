@ Program to determine the frequency of the processor

.equ O_RDONLY, 0
fd .req r5
bytes .req r4

    .text
    .global E4235_WhatAmI

@ entry point - stores used registers
E4235_WhatAmI:
    push {lr}
    push {r1-r7}
    mov r6, #0

@ opens file with cpu max frequency info
open:
    ldr r0, =filename   @ filename
    mov r1, #O_RDONLY   @ flags for open
    mov r7, #5          @ system call for open
    svc #0
    mov fd, r0

@ reads cpu max file
read:
    mov r0, fd          @ file descriptor
    ldr r1, =return     @ data space for return value
    mov r2, #24         @ number of bytes to read
    mov r7, #3
    svc #0
    sub r0, r0, #2      @ number of tens places we have
    mov bytes, r0       @ stores number of bytes read

@ closes cpu max file
close:
    mov r0, fd
    mov r7, #6
    svc #0

@ calculate return value
getNumber:
    ldrb r2, [r1]       @ loads first byte of return variable
    sub r2, r2, #0x30   @ converts from ASCII to decimal
    mov r0, bytes
    bl multiply         @ moves current byte into correct decimal place
    add r6, r6, r2      @ adds current byte to result
    add r1, r1, #1      @ increment counter
    subs bytes, bytes, #1 @ decrement current bytes left
    bne getNumber
    b exit

@ multiples to convert byte to decimal number
multiply:
    mov r3, #10         @ converting to base 10
    mul r2, r2, r3      @ intermediate result stored in r2
    subs r0, r0, #1     @ decrement counter
    bne multiply
    bx lr

exit:
    mov r0, r6          @ move result into return register r0
    mov r6, #1000       @ convert to GHz
    mul r0, r0, r6

    pop {r1-r7}
    pop {lr}
    bx lr

.data
filename:
    .asciz "/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq"

return:
    .space 24
