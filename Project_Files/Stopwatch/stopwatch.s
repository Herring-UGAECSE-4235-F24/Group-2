@This is a delay program for 4230.  Your RP4 either runs at 1.5 or 1.8GHZ.  Using the program determine what speed your PI appears to be running
@Deliverable 1:  Calculate your RP4 clock speed.  Show how.
@Now let's make a stopwatch.   Use RP9:RP8:RP7 for minutes:seconds:hundredths of seconds.  Output the free running time to the terminal.  At 2:00:000, the stopwatch should go back to 0:00:00 and keep running.
@You should look at the printloop.s example for the use of the printf command.  You will probably need to investigate formating using the asciz data type.
@Deliverable 2: your code on github and in your writeup.  We will check in class and look at accuracy as well.
.global main
.include "./deblock.s"
@.func main

main:
	@ init minute counter to 0
	MOV R9, #0
	MOV R6, #0
	@ R6 = 0 : stop state
	@ R6 = 1 : run state
	@ R6 = 2 : lap state
	@ R6 = 3 : clear state
	
minuteLoop:
	@ init second counter to 0
	MOV R8, #0

secondLoop:
	@ init millisecond counter to 0
	LDR R7, =0

milliLoop:
	@ format the time from using the string and the 123 registers
	LDR R0, =time_format
	MOV R1, R9              
	MOV R2, R8
	MOV R3, R7
	
	@ compare to see if you need to print
	cmp R6, #0
	beq noprint
	cmp R6, #2
	beq noprint
	BL printf

noprint:	
	MOV R4, #0
	mov r0, #1
    bl  E4235_KYBdeblock
    
@ read from stdin
read:
	push {r0-r10}
	mov r0, #0	@ file descriptor for stdin
	mov r2, #4	@ allocates bytes to read
	mov r7, #3	@ svc read
	ldr r1, =input
	str r0, [r1]	@ reset input
	svc 0
	ldrb r11, [r1]	@ read byte in input
	pop {r0-r10}
	
reations:
	@ IF R IS ENTERED (RUN)
	cmp r11, #'r'
	beq run
	@ IF L IS ENTERED (LAP)
	cmp r11, #'l'
	beq lap
	@ IF S IS ENTERED (STOP)
	cmp r11, #'s'
	beq stop
	@ IF C IS ENTERED (CLEAR)
	cmp R11, #'c'
	beq clear
	@ IF PROGRAM IS STOPPED
	cmp R6, #0
	beq read
	@ IF PROGRAM IS RUNNING
	cmp R6, #1
	beq decLoop
	@ IF PROGRAM IS LAPPING
	cmp R6, #2
	beq decLoop

stop:
	@ format the time from using the string and the 123 registers
	LDR R0, =time_format
	MOV R1, R9              
	MOV R2, R8
	MOV R3, R7
	BL printf
	
	mov R6, #0
	B read
lap:
	cmp r6, #0
	BEQ read
	mov R6, #2
	B decLoop
run:
	mov R6, #1
	B decLoop
clear:
	mov R6, #0
	B clear_print

decLoop:
	
	@ decrement
	ADDS R4, #1               
	LDR R10, =9000000
	SUBS R10, R4                
	BNE decLoop

	@ decrement hundreths
	ADDS R7, #1
	LDR R10, =100              
	SUBS R10, R7                
	BNE milliLoop

	@ decrement seconds
	ADDS R8, #1
	LDR R10, =60               
	SUBS R10, R8            
	BNE secondLoop

	@ logic for resetting back to 0 when 2 minutes is reached
	ADDS R9, #1
	CMP R9, #60                  
	BNE minuteLoop                   
	MOV R9, #0
	B minuteLoop

clear_print:
	LDR r0, =dummy_print
	BL printf
	b main


cancel:
	mov r7, #1
    svc 0
    @BAL main
    @POP {PC}

.data
dummy_print:
	.asciz "00:00:00\n"
time_format:	
	.asciz "%02d:%02d:%02d\n"
input:
    .asciz "%c"


