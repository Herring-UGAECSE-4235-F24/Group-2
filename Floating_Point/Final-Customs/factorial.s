
.section .text
.global factorial

factorial:
    push {lr}
    // Input x0 contains the factorial number
	
    // Initialize result to 1.0 (since factorial starts at 1)
    vmov.f32 s1, s0
    vmov.f32 s2, s1
    vmov.f32 s3, #1.0 // 6.0
    vmov.f32 s9, #1.0 // this is used to decrement
    
    bl factorialLoop

    // Check if n is 0 or 1, in which case factorial is 1
    //cmp r3, #0
    vcmp.f32 s1, #0.0
    blt endOfCode

factorialLoop:

    // Decrement n
    vcmp.f32 s1, #0.0
    VMRS r7, FPSCR
    and r7, r7, #0x40000000
    ldr r8, =1610612736
    cmp r7, #0x40000000
    beq endOfCode
    vmul.f32 s3, s3, s1
    vsub.f32 s1, s1, s9
    b factorialLoop
    
endOfCode:
	vmov.f32 s0, s3
	pop {lr}
	bx lr

