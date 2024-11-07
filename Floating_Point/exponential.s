	.text
	.global main
	.func main

main:
	@ Ask user for input value x
x_input:
	ldr r0, =promptx  @ Load the address of promptx into r0
	bl printf          @ Call printf to display the prompt for x

	@ Read user input for x
	ldr r0, =xFormat
	mov r1, SP
	bl scanf
	vldr d1, [SP]
	vcvt.f64.f32 d1, s0
	ldr r1, [SP]
	ldr r1, =n

	@ Check if x is negative and prompt for re-entry if so
	cmp r3, #0
	blt x_input



	@ Ask user for input value n
n_input:
	ldr r0, =prompt
	bl printf

	@ Read user input for n
	ldr r0, =nFormat
	ldr r1, =nStore
	bl scanf
	ldr r3, =nStore
	ldr r3, [r3]

	@ Check if n is negative and prompt for re-entry if so
	cmp r3, #0
	blt n_input
	
	@ Check if n is 0 and print 1 because its 1
	cmp r3, #0
	beq printOne


Exponential:
	mov r5, r3
	vmov.f32 s2, s0
	sub r3, #1

loop:
	vmul.f32 s0, s0, s2
	subs r3, #1
	bne loop

print:
	vcvt.f64.f32 d1, s0
	ldr r0, =output
	vmov r1, r3, d1
	bl printf
	b end

printOne:
	ldr r0, =printWon
	bl printf

end:
	mov r7, #1   
	swi 0      

.data
printWon: .asciz "1.000000\n"
output:	.asciz "%lf\n"
prompt:	.asciz "Enter n: "
promptx: .asciz "Enter x: "
xFormat:	.asciz "%f" 
nFormat: 	.asciz "%i" 
nStore: .word 0   
xStore:	.word 0         
n: 	.space 4          
