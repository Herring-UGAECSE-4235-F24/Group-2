.data
prompt: .asciz "Calculate n!. Enter n: "
format: .asciz "%f"
resultFormat: .asciz "%d! = "
result2:    .asciz "%f\n" 
n: .float 0
result: .space 8

.text
.global main
main:
	PUSH {LR}
    // Print the prompt
    ldr r0, =prompt
    bl printf

    // Read the input from the user
    ldr r0, =format
    ldr r1, =n
    PUSH {r1}
    bl scanf
    
    // Load n from memory
    POP {r1}
    ldr r6, [r1] // r1, =n
    cmp r6, #0
    blt main
    // vldr s1, [r1]
    // Initialize result to 1.0 (since factorial starts at 1)
    vmov.f32 s1, #5.0
    vmov.f32 s2, s1
    vmov.f32 s3, #1.0 // 6.0
    vmov.f32 s9, #1.0 // this is used to decrement
    
    bl factorialLoop

    // Check if n is 0 or 1, in which case factorial is 1
    //cmp r3, #0
    vcmp.f32 s1, #0.0
    blt printResult

factorialLoop:

    // Decrement n
    vcmp.f32 s1, #0.0
    VMRS r7, FPSCR
    ldr r8, =1610612736
    cmp r7, r8
    beq printResult
    vmul.f32 s3, s3, s1
    vsub.f32 s1, s1, s9
    b factorialLoop
    
    /*
    vsub.f32 s1, s1, s3
    vcmp.f32 s1, #0.0
    beq printResult
    vmul.f32 s1, s1, s3
    ble factorialLoop
    */
    


printResult:
    // Load result format string
    ldr r0, =resultFormat

    // Load n from memory for printing
    ldr r1, =n
    ldr r1, [r1]

    // Load the factorial result into s0
    vmov.f32 s0, s3


    // Print the result
    bl printf
    
    
	vcvt.f64.f32 d1, s3
    ldr r0, =result2
	vmov r1, r3, d1

    
    bl printf
    
    // Exit the program
    POP {PC}
    MOV PC, LR
