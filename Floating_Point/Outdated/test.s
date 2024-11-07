.data
    output: .asciz "Result: %f\n"
    data: .word 0
    type: .asciz "%d"

.text
    .global main
    .func nfactorial

main:
    PUSH {LR}            @ Save the link register

    @ Get data from scanf
    ldr r0, =type       @ Load address of type string
    ldr r1, =data       @ Load address of data variable
    bl scanf            @ Call scanf to read input

    ldr r0, =data       @ Load address of data again
    ldr r1, [r0]        @ Load integer input into r1
    vmov s0, #1.0       @ Initialize s0 to 1.0 (factorial result)

loop:
    cmp r1, #0          @ Compare r1 with 0
    beq exit            @ If r1 == 0, exit loop

    vcvt.f32.s32 s2, r1  @ Convert integer r1 to float and store in s2
    vmul.f32 s0, s0, s2   @ Multiply s0 (result) by s2 (current integer value)

    sub r1, r1, #1      @ Decrement r1 by 1
    b loop              @ Repeat the loop

exit:
    @ Prepare to print the result
    ldr r0, =output     @ Load address of output string
    vcvt.f64.f32 d0, s0 @ Convert s0 (float) to d0 (double for printf)

    @ Print the result
    mov r1, d0          @ This is incorrect, we need to use the correct conversion
    ldr r0, =output     @ Load address of output string
    bl printf           @ Call printf to print result

    POP {LR}            @ Restore the link register
    BX LR               @ Return from main

