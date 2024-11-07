	
.global main

main:
	vmov.f32	s0, #0.125 @ vmov
	vmul.f32 	s0, s0, s0
	ldr	r2, =piNumber
	vldr		s1, [r2]
	vmul.f32	s0, s0, s1
	
	@ print out area
	vcvt.f64.f32 d0, s0
	ldr r0, =printFormat
	vmov.f32 r1, r2, d0
	bl printf
	
	@ end program
	mov r7, #1
	svc 0



.data
piNumber: 
	.float 3.141593
printFormat:
	.asciz "Area of Circle:" 
