
@	Assembly program to read from a series of gpio pins,
@	mimicking a bus
@
@	uint16_t E4235_multiread(int[], int)
@
@	input:
@		R0 - array of pin numbers
@				- if a series of numerically ordered pins are wanted,
@				the format [#, '-', #] can be used
@				- cannot exceed 16 pins
@		R1 - length of the array (how many elements)
@
@	output:
@		R0 - level value
@				-1 = invalid

	.global E4235_multiread
	.extern E4235_read

E4235_multiread:
		push {r2 - r12, lr}	@ r0 = user gpio array, r1 = length of array
		ldr r3, =arr
iterate:
		ldr r4, [r0], #4
		cmp r4, #45			@ decimal for '-' character
		bne store			@ if not in "# - #" format, store normally
		sub r1, r1, #1
		ldr r5, [r0, #-8]	@ r5 holds starting value in "# - #" format
		ldr r6, [r0]		@ r6 holds ending value in "# - #" format
inbtw:						@ iterates through "# - #" notation
		add r5, r5, #1
		str r5, [r3], #4
		cmp r5, r6
		bne inbtw
		add r0, r0, #4
		b count
store:
		str r4, [r3], #4
count:
		sub r1, r1, #1
		cmp r1, #0
		bne iterate
		mov r5, #-1			@ ending character of arr
		str r5, [r3]
		cmp r7, #16			@ maximum amount of pins
		bgt errorpin
		ldr r4, =arr
		ldr r5, =in
read:
		ldr r0, [r4], #4
		cmp r0, #-1			@ looking for ending character
		beq endok
		bl E4235_read		@ input(r0 before) = gpio pin number, output(r0 after) = level value
		ldr r1, =in
		ldr r1, [r1]
		lsl r1, #1 
		add r0, r1, r0
		str r0, [r5]
		b read
endok:
		ldr r0, =in
		ldr r0, [r0]
end:
		pop {r2 - r12, lr}
		bx lr
errorpin:
		ldr r0, =pinerrormsg
		bl printf
		mov r0, #-1
		b end
		
		.data
		pinerrormsg: .ascii "The number of pins is not valid.\n"
		in: .zero 16
		arr: .zero 131072
		
