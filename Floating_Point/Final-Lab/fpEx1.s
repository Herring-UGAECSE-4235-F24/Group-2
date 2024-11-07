@ Group assignment
@ This program calculates the area of a circle
@ use gdb info all-registers  or i all-r
@ Change the code to print the results to the monitor in correct format.
@ We will check in class.  Be ready to change the radius value and re-run

.text
.global main

main:
	@ do the math regarding circle
	vmov.f32	s14, #0.125
	vmul.f32 	s14, s14, s14
	ldr	r6, =piNumber
	vldr		s15, [r6]
	vmul.f32	s14, s14, s15

	@ print something
	vcvt.f64.f32 d7, s14
	LDR R0, =dummy_print
	vmov r2, r3, d7
	BL printf
	
	@ end
	mov r7, #1
    svc 0
	
.data
piNumber: 
	.float 3.141593
dummy_print:
	.asciz "Area of Circle: %f\n"

