.global main 
main:
mov R0, #21
mov R1, #1

bl gPIOwrite

mov R0, #20
mov R1, #1

bl gPIOread


mov     R0, #0          @use 0 return code
mov     R7, #1          @service command code 1
svc     0