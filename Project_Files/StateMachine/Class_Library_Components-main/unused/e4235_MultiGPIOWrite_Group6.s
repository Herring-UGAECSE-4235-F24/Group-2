.text
.global e4235_MultiGPIOWrite
e4235_MultiGPIOWrite:   
@R0 should hold current gpio to send to write
@R1 is static and can hold 0 or 1 for write high/low
@R2 is static and holds address passed in from R0
@R3 can hold first digit of gpio
@R4 can hold second digit of gpio
@R5 holds current gpio when writing to multiple
@R6 holds max gpio when writing to multiple
@R7 is high when null character is met, meaning end of string
@R8 will hold counter of how many digits are in gpio number
@R9 spare register - holds lr address in some cases
@R10 will hold 3rd digit if needed (either - or space)


    push {lr}
    push {r0-r12}
    ldr r2, =SP_BLOCKTWO
    str sp, [r2]

    mov     R2, R0
    mov     R8, #0
    mov     R7, #0
    b       center

@Loop that put GPIO value into R0 if the GPIO only uses one number place
oneDigit:
    subs    r3, r3, #48
    mov     R0, r3
    bx      lr

@Loop that put GPIO value into R0 if the GPIO uses two number places
@Both of these should bl back to condition of space vs -
twoDigits:
    mov     R0, #0
    mov     R9, lr
    subs    r3, r3, #48
    subs    r4, r4, #48
l1:     
    add     R0, R0, #10
    sub     R3, R3, #1
    cmp     R3, #0
    bne     l1
    @Now add least significant digit to R0
    add     R0, R0, R4
    mov     lr, R9
    bx      lr



@If there's no 'group' of gpio values, write to the one gpio in r0
writeSingle:
    push {lr}
    push {r0-r12}
    ldr r2, =SP_BLOCK
    str sp, [r2]
    bl      gPIOwrite
    ldr r12, =SP_BLOCK
    ldr sp, [r12] 
    pop {r0-r12}
    pop {lr}
    cmp     R7, #1
    beq     end
    b       center

@Reads single GPIO, shifts R7 left and or's it with R0 value
readSingle:

@Given current GPIO in R6, write to current, increment current gpio in r6, decrement R5 value 
writeMultiple:

@Given current GPIO in R6, read current, add to read output in r7, increment current gpio in r6, decrement r5 until it hits 0
readMultiple:

@Dash Case - first, get gpio into r5 (current), then load next 2 into r6 (max)
@Then start another loop of calling gpioWrite, incrementing r5, checking if it is greater than r6 and repeating
@Then return to center
dash:
    cmp     R8, #1
    bleq    oneDigit
    cmp     R8, #2
    bleq    twoDigits
    mov     R5, R0
    @Load next into R6
    ldrb    r3, [r2], #1
    mov     R8, #1
    ldrb    r4, [r2], #1
    @Case of second digit being null
    cmp     r4, #0
    moveq   r7 , #1
    cmp     r4, #0
    bleq    oneDigit
    cmp     r4, #0
    moveq   R6 , R0
    cmp     r4, #0
    beq     writeLoop
    @Case of second digit being space
    cmp     r4, #32
    bleq    oneDigit
    cmp     r4, #32
    moveq   R6 , R0
    cmp     r4, #32
    beq     writeLoop
    cmp     r4, #32
    beq     writeLoop
    @case of Second digit being number and 3rd being null
    add     r8, r8, #1
    ldrb    r10, [r2], #1
    cmp     r10, #0
    moveq   r7, #1
    cmp     r10, #0
    bleq    twoDigits
    cmp     r10, #0
    moveq   R6, R0
    @3rd is space
    cmp     r10, #32
    bleq    twoDigits
    cmp     r10, #32
    moveq   R6, R0
writeLoop:
    cmp     R5, R6
    bgt     checkEnd
    mov     R0, R5
    push {lr}
    push {r0-r12}
    ldr r2, =SP_BLOCK
    str sp, [r2]
    bl      gPIOwrite
    ldr r12, =SP_BLOCK
    ldr sp, [r12] 
    pop {r0-r12}
    pop {lr}
    add     R5, R5, #1
    b       writeLoop


checkEnd:
    cmp     R7, #1
    beq     end
    b       center

@If this case is reached, then there is a space after the current gpio, however there may be one or two digits in the GPIO
@This puts the gpio value into R0, then calls read or write
determineReadorWriteSingle:
    cmp     R8, #1
    bleq     oneDigit
    cmp     R8, #2
    bleq     twoDigits
    b      writeSingle

@center logic Loop
center:
    ldrb    r3, [r2], #1
    cmp     R3, #0
    beq     end
    mov     R8, #1
         

secondDigit:
    ldrb    r4, [r2], #1
    cmp     r4, #0
    moveq   r7 , #1
    cmp     r4, #0
    beq     determineReadorWriteSingle
    cmp     r4, #32
    beq     determineReadorWriteSingle
    cmp     r4, #45
    beq     dash
    add     R8, R8, #1

thirdDigit:
    ldrb    r10, [r2], #1
    cmp     r10, #0
    moveq   r7, #1
    cmp     r10, #0
    beq     determineReadorWriteSingle
    cmp     r10, #32
    beq     determineReadorWriteSingle
    cmp     r10, #45
    beq     dash

end:
    ldr r12, =SP_BLOCKTWO
    ldr sp, [r12] 
    pop {r0-r12}
    pop {lr}
    bx lr

.data
s1:
    .asciz "1-2"

output:
    .asciz "%c\n"
SP_BLOCK:
    .word 0
SP_BLOCKTWO:
    .word 0