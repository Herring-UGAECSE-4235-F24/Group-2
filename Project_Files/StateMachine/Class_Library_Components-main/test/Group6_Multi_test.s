.text
.global main

main:
ldr r0, =input
mov r1, #1
bl e4235_MultiGPIOWrite
ldr r0, =input2
bl e4235_MultiGPIORead
mov r5, r0
cmp r5, #0b11
bne end
ldr r0, =output
bl printf

end: b end 

.data
output: .asciz "Pins are High"
input: .asciz "18 23-24"
input2: .asciz "4 2-3" 

