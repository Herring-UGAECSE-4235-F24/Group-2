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
	.global _start
_start:	 adr	r2, lookup		@ point to lookup 
	 ldrb	r10, [r2, r9]	@ r10 = entry of lookup table index by r9
	mov	r7,#1
	svc	0

lookup: .byte	3, 6, 11, 18, 27, 38, 51, 66, 83, 102

