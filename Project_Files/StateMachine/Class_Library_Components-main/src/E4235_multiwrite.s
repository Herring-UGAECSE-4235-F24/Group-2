
@	Assembly program to write a value to a series of gpio pins,
@	mimicking a bus.
@	
@	int E4235_multiwrite(int[], int, uint16_t
@
@	input:
@		R0 - array of pin numbers
@				- if a series of numerically ordered pins are wanted,
@				the format [#, '-', #] can be used
@				- cannot exceed 16 pins
@				- if a pin is repeated the value assigned to the second
@				time will be written
@		R1 - length of the array (how many elements)
@		R2 - value to write
@
@	output:
@		R0 - validity
@				-1 = invalid

	.global E4235_multiwrite
	.extern E4235_Write

E4235_multiwrite:
		push {r3 - r12, lr}	@ r0 = user gpio array, r1 = length of array, r2 = value to write
		ldr r10, =value
		str r2, [r10]		@ store value to write in value variable
		mov r7, #0			@ r7 holds number of gpio pins entered
		ldr r3, =arr		@ arr holds the actual gpio pin numbers
iterate:					
		ldr r4, [r0], #4
		cmp r4, #45			@ decimal equivalent of '-' character
		bne store			@ if not in "# - #" format, store normally
		sub r1, r1, #1
		ldr r5, [r0, #-8]	@ r5 holds starting value in "# - #" format
		ldr r6, [r0]		@ r6 holds ending value in "# - #" format
inbtw:						@ iterates through "# - #" notation
		add r5, r5, #1
		str r5, [r3], #4
		add r7, r7, #1
		cmp r5, r6
		bne inbtw
		add r0, r0, #4
		b count
store:
		str r4, [r3], #4
		add r7, r7, #1
count:
		sub r1, r1, #1
		cmp r1, #0
		bne iterate
		mov r5, #-1			@ ending character of arr
		str r5, [r3]
		cmp r7, #16			@ maximum amount of pins
		bgt errorpin
		ldr r4, =arr
		ldr r5, =value
write:
		@ insert custom binary vector parsing
		ldr r6, [r5]		@ r6 holds the value to be set
		cmp r7, #0
		beq end
							@ value parsing
		mov r0, #16			@ max amount of pins
		sub r8, r0, r7
		add r8, r8, r0		@ amount to lsl by
		lsl r6, r6, r8		@ get rid of prior bits
		lsr r6, #31			@ get rid of later bits
							@ r6 holds level of certain bit
		ldr r0, [r4], #4	@ r0 = pin to set level
		mov r1, r6			@ r1 = level value
		bl E4235_Write
		cmp r0, #-1			@ if error
		beq end				@ end function and return -1
		sub r7, r7, #1
		b write
end:
		pop {r3 - r12, lr}
		bx lr
errorpin:
		ldr r0, =pinerrormsg
		bl printf
		mov r0, #-1
		b end
		
		.data
		pinerrormsg: .ascii "The number of pins is not valid.\n"
		arr: .zero 131072
		value: .zero 64
		
