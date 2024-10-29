@
@ Assembly program to call function to set pullup/down of gpio

.global main
main:
	mov r0, #24
	mov r1, #2
	bl E4235_gpio_set_pud
exit:
	mov r7, #1
	svc 0

.data
	msg: .asciz "ERROR: Please ensure your call is in form 'E4235_gpio_set_pud(x,y)' where:\n	1 < x < 28\n	0 < y < 3\n"
