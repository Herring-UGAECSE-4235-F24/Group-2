@
@ Assembly program to call Assembly delays
@ Note: All functions tested with a common delay of 1 minute except for the nanosecond delay,
@ which uses a delay of 1/2 second to output a 1 Hz signal.
@

.global main

main:
	@ change the branch location according the function you want to test.
	@ NS - Nanoseconds  | McS - Microseconds | MiS - Milliseconds
	@ CS - Centiseconds | Sec - Seconds      | Min - Minutes
	
	b CS

@ Because of how small a time period  delayNS works with, the testing method utilizes the delay to
@ generate a 1 Hz signal which can be checked via O-scope, instead of simply using a stopwatch to 
@ check accuracy as with the other functions.
NS:
	ldr r0, = 500000000 @ 500,000,000 ns delay for 1/2 sec
	bl E4235_Delaynano
	b exit

@ Delays for a minute using the delayMcS function, check accuracy with a stopwatch.
McS:
	ldr r0, =60000000
	bl E4235_Delaymicro
	b exit

@ Delays for a minute using the delayMiS function, check accuracy with a stopwatch.
MiS: 
	ldr r0, =60000
	bl E4235_Delaymilli
	b exit

@ Delays for a minute using the delayCS function, check accuracy with a stopwatch.
CS:
	ldr r0, =6000
	bl E4235_Delaycenti
	b exit

@ Delays for a minute using the delaySec function, check accuracy with a stopwatch.
Sec:
	ldr r0, =60
	bl E4235_Delaysec
	b exit

@ Delays for a minute using the delayMin function, check accuracy with a stopwatch.	
Min: 
	ldr r0, =1
	bl E4235_Delaymin
	b exit
	
exit:
	mov r7, #1
	svc 0
