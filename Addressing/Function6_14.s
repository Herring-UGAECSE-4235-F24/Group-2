@ **NOTE: THIS IS A GROUP ASSEMBLY ASSIGNMENT**

@this code calculates x^2 + 2x + 3 with "x" stored in r9 which you will need to add to the program.  
@Deliverable 1: What is the range of valid values for r9?
@Deliverable 2: Show your code written with R9 added so that it runs with "x = 3".
@Deliverable 3: How many clocks does this take to execute?
@Deliverable 4: Rewrite the function without using a lookup table. Show your code working with "x = 3".  How many clocks to run?
@Deliverable 5: What are pros and cons of the two methods: 1) Look-up table, 2) Mathematical function.


@Deliverable 6: Now write a program with a look-up table that takes a degree value from 0-90 (including 0 and 90) in multiples of 4 (0, 4, 8, 12, etc...) and stores into R9 from the keyboard input.
@ The program will use the degree value and return the sin x 1000 in R0 and the cosine x 1000 in R1 (so this is to 3 decimal places).  For example if R9 = 32, R0 would have 530 and r1 would have 848.  
@ Display the result on the terminal in decimal correctly and with the following format using the example with 32 as the angle...
@ Cosine of 32 = 0.530 and Sine of 32 = 0.848
@ Show your code in your writeup.
@ Code steps: 1) Ask for input "Enter Angle:", 2) If not within range, do nothing, 3) If within range, display the output result and go back to 1) for new input.
@ Deliverable 7: I will check results in class.


	.text
	.global main
	.include "./scanf.s"
main:

	@ code to write message
	ldr r0, =message
	bl printf
	
	@ code to scan in number
	ldr r0, =input
	ldr r1, =value
	bl scanf

	ldr r3, =value
	ldr r3, [r3]
	
	@ldr r0, =input
	@mov r1, r3
	@bl printf
	
	@ make sure its in range
	cmp r3, #90
	bgt restart
	cmp r3, #0
	blt restart
	
	@ do the math
	mov r1, r3
	
	@ lookup value for cos and print
	adr r8, cos         @ Load cos table address
    ldr r2, [r8, r3]    @ r1 = cos(x) * 1000
    
    @ check printing type for value
    cmp r2, #34
    beq cos34
    cmp r2, #1000
    beq cos1
    b regcos
    
    @ print types
cos1:
	ldr r0, =cos1Print
	b printcos
cos34:
	ldr r0, =cos34Print
	b printcos
regcos:
	ldr r0, =cosPrint     @ Load result message format string
	
	@ code to print cos
printcos:
	PUSH {R0-R10}
    bl printf                  @ Print the result
    POP {R0-R10}
    
    @ lookup value for sin and print
    adr r8, sin         @ Load cos table address
    ldr r2, [r8, r3]   @ r1 = cos(x) * 1000
    
    @ check printing type for value
    cmp r2, #70
    beq sin70
    cmp r2, #1000
    beq sin90
    b regsin
    
    @ print types
sin90:
	ldr r0, =sin90Print
	b printsin
sin70:
	ldr r0, =sin70Print
	b printsin
regsin:
	ldr r0, =sinPrint     @ Load result message format string
	
	@ code to print sin
printsin:
	PUSH {R0-R10}
    bl printf                  @ Print the result
    POP {R0-R10}

restart:
	b main


	
sin:
	.word 0, 70, 139, 208, 276, 342, 406, 469, 530, 588, 643, 695, 743, 788, 829, 866, 899, 927, 951, 970, 985, 995, 999, 1000
cos:
	.word 1000, 998, 990, 978, 961, 940, 914, 883, 848, 809, 766, 719, 669, 616, 559, 500, 438, 375, 309, 242, 174, 105, 34, 0

	.data
value:
	.word 0
input:
	.asciz "%d"
message:
	.asciz "Enter Angle:\n"
cosPrint:
	.asciz "Cosine of %d = 0.%d and "
cos1Print:
	.asciz "Cosine of %d = 1.000 and "
cos34Print:
	.asciz "Cosine of %d = 0.0%d and "
sinPrint:
	.asciz "Sine of %d = 0.%d \n"
sin90Print:
	.asciz "Sine of %d = 1.000 \n"
sin70Print:
	.asciz "Sine of %d = 0.0%d \n"

