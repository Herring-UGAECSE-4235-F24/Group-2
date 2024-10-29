	
	.text
	.global main

main:	
	ldr r0, =arrin
	mov r1, #2
	mov r2, #2
	bl E4235_multiwrite
	
	ldr r0, =arrout
	mov r1, #4
	bl E4235_multiread
	
	bl printf

	.data
	arrin: .word 22, 6
	arrout: .word 23, '-', 25, 26
