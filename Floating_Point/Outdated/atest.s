.data
prompt: .asciz "Calculate n!. Enter n: "
format: .asciz "%d"
resultFormat: .asciz "%d! = "
result2: .asciz "%f\\n" 
n: .space 4
result: .space 8

.text
.global main
main:
    // Print the prompt
    ldr r0, =prompt
    bl printf

    // Read the input from the user
    ldr r0, =format
    ldr r1, =n
    bl scanf

    // Load n from memory
    ldr r1, [r1]
    cmp r1, #0
    blt main // If n < 0, prompt again (factorial is not defined for negative numbers)

    // Initialize result to 1 (factorial starts at 1)
    mov r2, #1 // r2 will hold the factorial result
    mov r3, r1 // r3 will hold the current value of n for the loop

factorialLoop:
    // Multiply result by n
    mul r2, r2, r3

    // Decrement n
    sub r3, r3, #1

    // Check if n is greater than 1
    cmp r3, #1
    bgt factorialLoop // Repeat if n > 1

printResult:
    // Load result format string
    ldr r0, =resultFormat

    // Load n for printing
    ldr r1, =n

    // Print the result
    mov r0, r1 // Move n to r0 for printf
    bl printf

    // Print the factorial result
    ldr r0, =result2
    vmov s0, r2 // Move the result to a floating-point register
    vcvt.f64.f32 d0, s0 // Convert the result to double
    bl printf // Print the result

    // Exit the program
    mov r7, #1
    swi 0
