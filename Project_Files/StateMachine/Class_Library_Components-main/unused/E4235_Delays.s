
 clockSpeed .req r12


@ start of file and global all functions to use in C and Asssembly Calling
	.text

    .text
	.cpu cortex-a7
	.global initDelay
	.global E4235_Delaymicro
	.global E4235_Delaymilli
	.global E4235_Delaycenti
	.global E4235_Delaysec
	.global E4235_Delaymin
	.global E4235_Delaynano

initDelay:
	push {r1-r2}
	mov clockSpeed, r0					@ user input = clockSpeed
	mov r1,#2							@ r1 = 2
	udiv clockSpeed, clockSpeed,r1		@ clock speed / 2
	ldr r1,=currentClock				@ r1 = mem address of currentClock
	str clockSpeed,[r1]					@ store clock for access
	pop {r1-r2}
	bx lr


@ beginning of delayseconds Function
E4235_Delaymin:
	push {r0 - r1}				@ push registers r0 - r1

	ldr r2,=currentClock 		@ load current clock address
	ldr r3, [r2]				@ r3 = current clock
	ldr r4, =1			@ r4 = 1000
	udiv r3, r3, r4				@ r3 = current clock / 1,000,000
	ldr r2,=calcClock			@ load calc Clock to r2
	str r3,[r2]					@ store r3 for usage
	mov r5, #60	
	mul r0, r0,r5 
Min1:	
	ldr r1, [r2]		@ r1 = clock that was stored
Min2: 
	subs r1, r1, #1		@ r1 = r1 – 1, decrement r1
	bne Min2				@ repeat it until r1 = 0 
	subs r0, r0, #1		@ decrement minutes inputted
	bne Min1				@ reset R1
	pop {r0 - r1}		@ pop registers r0 - r1
    bx lr				@ branch to LR value 



@ beginning of delayseconds Function
E4235_Delaysec:
	push {r0 - r1}				@ push registers r0 - r1

	ldr r2,=currentClock 		@ load current clock address
	ldr r3, [r2]				@ r3 = current clock
	ldr r4, =1			@ r4 = 1000
	udiv r3, r3, r4				@ r3 = current clock / 1,000,000
	ldr r2,=calcClock			@ load calc Clock to r2
	str r3,[r2]					@ store r3 for usage

S1:	
	ldr r1, [r2]		@ r1 = clock that was stored
S2: 
	subs r1, r1, #1		@ r1 = r1 – 1, decrement r1
	bne S2				@ repeat it until r1 = 0 
	subs r0, r0, #1		@ decrement seconds inputted
	bne S1				@ reset R1
	pop {r0 - r1}		@ pop registers r0 - r1
    bx lr				@ branch to LR value 


@ beginning of delaycenti Function
E4235_Delaycenti:
	push {r0 - r1}				@ push registers r0 - r1

	ldr r2,=currentClock 		@ load current clock address
	ldr r3, [r2]				@ r3 = current clock
	ldr r4, =100				@ r4 = 100
	udiv r3, r3, r4				@ r3 = current clock / 1,000,000
	ldr r2,=calcClock			@ load calc Clock to r2
	str r3,[r2]					@ store r3 for usage

C1:	
	ldr r1, [r2]		@ r1 = clock that was stored
C2: 
	subs r1, r1, #1		@ r1 = r1 – 1, decrement r1
	bne C2				@ repeat it until r1 = 0 
	subs r0, r0, #1		@ decrement centseconds inputted
	bne C1				@ reset R1
	pop {r0 - r1}		@ pop registers r0 - r1
    bx lr				@ branch to LR value 


@ beginning of delaymilli Function
E4235_Delaymilli:
	push {r0 - r1}				@ push registers r0 - r1

	ldr r2,=currentClock 		@ load current clock address
	ldr r3, [r2]				@ r3 = current clock
	ldr r4, =1000				@ r4 = 1000
	udiv r3, r3, r4				@ r3 = current clock / 1,000,000
	ldr r2,=calcClock			@ load calc Clock to r2
	str r3,[r2]					@ store r3 for usage

M1:	
	ldr r1, [r2]		@ r1 = clock that was stored
M2: 
	subs r1, r1, #1		@ r1 = r1 – 1, decrement r1
	bne M2				@ repeat it until r1 = 0 
	subs r0, r0, #1		@ decrement milliseconds inputted
	bne M1				@ reset R1
	pop {r0 - r1}		@ pop registers r0 - r1
    bx lr				@ branch to LR value 



@ beginning of delayMicro Function
E4235_Delaymicro:
	push {r0 - r1}				@ push registers r0 - r1

	ldr r2,=currentClock 		@ load current clock address
	ldr r3, [r2]				@ r3 = current clock
	ldr r4, =1000000			@ r4 = 1,000,000
	udiv r3, r3, r4				@ r3 = current clock / 1,000,000
	ldr r2,=calcClock			@ load calc Clock to r2
	str r3,[r2]					@ store r3 for usage

mm1:	
	ldr r1, [r2]		@ r1 = clock that was stored
mm2: 
	subs r1, r1, #1		@ r1 = r1 – 1, decrement r1
	bne mm2				@ repeat it until r1 = 0 
	subs r0, r0, #1		@ decrement microSeconds inputted
	bne mm1				@ reset R1
	pop {r0 - r1}		@ pop registers r0 - r1
    bx lr				@ branch to LR value 

@ beginning of delayNano Function
E4235_Delaynano:
	push {r0}			@ push registers r0
Nan: 
						
	subs r0, #1			@ decrement User Input
	bne Nan				@ repeat until r0 = 0 ( User input = 0)
    pop {r0}			@ pop registers r0
	bx lr				@ branch to LR value 


.data 
	currentClock:
		.word 0
	calcClock:
		.word 0

	
	
