
@ Assembly program to return statistics of the rp4 the
@ program is being run on
@
@ int E42353_whatami(int)
@ 
@ input:
@   R0 - integer denoted which statistic
@           1 = cpu frequency
@
@ output:
@   R0 - statistic
@           -1 = invalid

.global E4235_whatami

E4235_whatami: 
    push {r1 - r7}

    // check which statistic
    cmp r0, #1
    beq frequency
    // insert other constants
    bne invalid // if none of them, return invalid

frequency:
    ldr r0, =file // arg 1: path
    mov r1, #0 // arg 2: flags
    mov r7, #5 //open
    svc 0 // file descriptor stored in r0

    ldr r1, =text // arg 2: pointer to place to store data
    mov r7, #3 //read
    svc 0 //if successful r0 has num bytes read

    // translates hex to integer
    mov r3, #0 // final place
    mov r4, #0 // incrementer
    sub r0, #1 // num of bytes from read function (last byte is \n so take it out)
    b hextoint
multiply:
    mov r6, #10
    mul r3, r6, r5
hextoint:
    ldrb r5, [r1, r4]
    sub r5, r5, #48 // 48 = ASCII 0 (zero) = 0x30
    add r5, r3, r5
    mov r3, r5
    add r4, #1
    subs r7, r0, r4
    bne multiply

    // multiply by #1000 to get GHz
    ldr r4, =#1000
    mul r3, r4, r3

    mov r0, r3
// insert other stats to find //
end:
    pop {r1 - r7}
    bx lr
invalid:
    mov r0, #-1
    b end

.data
file: .ascii "../../../../../sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq\000"
text: .asciz "%d"
