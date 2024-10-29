@ start of file and global all functions to use in C and Asssembly Calling
	.text
	.global E4235_delayMinutes
	.global E4235_delaySec
	.global E4235_delayCenti
	.global E4235_delayMili
	.global E4235_delayMicro
	.global E4235_delayNano

@ beginning of E_4235_delayMinutes Function
E4235_delayMinutes:	
	push {r0-r2}		@ push registers r0 - r2
	mov r2, #60 		@ r2 = 60
	mul r2, r2, r0 		@ r2 = r2 * UserInput
min1:	
	ldr	r1, =900000000	@ r1 = 900000000 
min2:	
	subs r1, r1, #1	@ r1 = r1 – 1, decrement r1
	bne	min2			@ repeat it until r1 = 0 
	subs r2, r2, #1		@ decerement minutes calculated
	bne min1			@ reset r1

	pop {r0-r2}			@ pop registers r0-r2
	bx lr				@ branch to LR value 


@ beginning of delaySec Function
E4235_delaySec:  
	push {r0 - r2}		@ push registers r0 - r2
	mov r2, #1			@ r2 = 1
	mul r2, r2, r0		@ r2 = r2 * UserInput
sec1:	
	ldr	r1, =900000000	@ r1 = 900000000
	
sec2:	
	subs r1, r1, #1		@ r1 = r1 – 1, decrement r1
	bne	sec2			@ repeat it until r1 = 0 
	subs r2, r2, #1		@ decerement minutes calculated
	bne sec1			@ reset r1

	pop {r0-r2}			@ pop registers r0-r2
	bx lr				@ branch to LR value 

@ beginning of delayCenti Function
E4235_delayCenti:
	push {r0 - r1}		@ push registers r0 - r1
c1:	
	ldr r1, = 9000000	@ r1 = 9000000
c2: 
	subs r1, r1, #1		@ r1 = r1 – 1, decrement r1
	bne c2				@ repeat it until r1 = 0 
	subs r0, r0, #1		@ decerement centiSeconds Inputted
	bne c1				@ reset R1
	pop {r0 - r1}		@ pop registers r0 - r1
    bx lr				@ branch to LR value 

@ beginning of delayMili Function
E4235_delayMili:
	push {r0 - r1}		@ push registers r0 - r1
m1:	
	ldr r1, = 900000	@ r1 = 900000
m2: 
	subs r1, r1, #1		@ r1 = r1 – 1, decrement r1
	bne m2				@ repeat it until r1 = 0 
	subs r0, r0, #1		@ decerement miliSeconds Inputted
	bne m1				@ reset R1
	pop {r0 - r1}		@ pop registers r0 - r1
    bx lr				@ branch to LR value 

@ beginning of delayMicro Function
E4235_delayMicro:
	push {r0 - r1}		@ push registers r0 - r1
mm1:	
	ldr r1, =900		@ r1 = 900
mm2: 
	subs r1, r1, #1		@ r1 = r1 – 1, decrement r1
	bne mm2				@ repeat it until r1 = 0 
	subs r0, r0, #1		@ decrement microSeconds inputted
	bne mm1				@ reset R1
	pop {r0 - r1}		@ pop registers r0 - r1
    bx lr				@ branch to LR value 

@ beginning of delayNano Function
E4235_delayNano:
	push {r0}			@ push registers r0
n2: 
						
	subs r0, #1			@ decrement User Input
	bne n2				@ repeat until r0 = 0 ( User input = 0)
    pop {r0}			@ pop registers r0
	bx lr				@ branch to LR value 
