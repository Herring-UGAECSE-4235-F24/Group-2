@
@ Group 7's Assembly program to set the PUD state of a given GPIO #
@
@ r0 - GPIO #
@ r1 - Pullup/Pulldown (1(01) - Pull-Up, 2(10) - Pull-Down)
@

@ Only GPIOs 2 - 27 should be accessed
.equ 	GPIO_PUP_PDN_CNTRL_REG0, 0xe4 	@ Offset for GPIOs 0 - 15
.equ 	GPIO_PUP_PDN_CNTRL_REG1, 0xe8 	@ Offset for GPIOs 16 - 31

@ Args for mmap
.equ 	OFFSET_FILE_DESCRP, 0	@ file descriptor
.equ    mem_fd_open, 3
.equ    BLOCK_SIZE, 4096        @ Raspbian memory page
.equ    ADDRESS_ARG, 3          @ device address

@ Misc
.equ	SLEEP_IN_S, 1

@ The following are defined in /usr/include/asm-generic/mman-common.h:
.equ    MAP_SHARED,1    @ share changes with other processes
.equ    PROT_RDWR,0x3   @ PROT_READ(0x1)|PROT_WRITE(0x2)

@ Constant program data
    .section .rodata
	device: .asciz  "/dev/gpiomem"
	msg: .asciz "ERROR: Please ensure your call is in form 'E4235_gpio_set_pud(x,y)' where:\n	1 < x < 28\n	0 < y < 3\n"

.text
.global E4235_gpio_set_pud
E4235_gpio_set_pud:
	PUSH {r2-r9,LR} @ Save the registers used
	
	@ Are the inputs valid?
	cmp r0, #2
	blt error
	cmp r0, #27
	bgt error
	cmp r1, #1
	blt error
	cmp r1, #2
	bgt error
	
	@ Move input registers to alternate locations so we can use mmap
	mov r8, r0
	mov r9, r1

	@ Open /dev/gpiomem for read/write and syncing
    ldr     r1, O_RDWR_O_SYNC   @ flags for accessing device
    ldr     r0, mem_fd          @ address of /dev/gpiomem
    bl      open     
    mov     r4, r0              @ use r4 for file descriptor
    
    @ Map the GPIO registers to a main memory location so we can access them
    @ mmap(addr[r0], length[r1], protection[r2], flags[r3], fd[r4])
    str     r4, [sp, #OFFSET_FILE_DESCRP]   @ r4=/dev/gpiomem file descriptor
    mov     r1, #BLOCK_SIZE                 @ r1=get 1 page of memory
    mov     r2, #PROT_RDWR                  @ r2=read/write this memory
    mov     r3, #MAP_SHARED                 @ r3=share with other processes
    mov     r0, #mem_fd_open                @ address of /dev/gpiomem
    ldr     r0, GPIO_BASE                   @ address of GPIO
    str     r0, [sp, #ADDRESS_ARG]          @ r0=location of GPIO
    bl      mmap
    mov     r3, r0		@ save the virtual memory address of base in r3
    
    @ Move input registers BACK into their original registers
    mov r0, r8
    mov r1, r9
    
    @ Branch to register breakdown based on r0
    cmp r0, #16
    
    blt reg0
    b reg1		@ if r0 is not < 16, must be < 28 for reg1

@ r3 contains address of base + offset
@ r4 contains the data @ address of base + offset
@ r5 contains shift value for masking
reg0:
	add r3, r3, #GPIO_PUP_PDN_CNTRL_REG0
	ldr r4, [r3] 	@ if within 2 - 15, load r4 w/ data from appropriate address
	mov r5, r0	@ load shift value with r0
	b masking
reg1:
	add r3, r3, #GPIO_PUP_PDN_CNTRL_REG1
	ldr r4, [r3]	@ if within 16 - 27, load r4 w/ data from appropriate address
	sub r5, r0, #16 @ load shift value with r0 - 16
	b masking

masking:
	lsl r5, r5, #1	@ shift r5 left by 1 (multiply by 2) to account for 16 GPIOs in 32 bit reg
	lsl r1, r1, r5	@ shift r1 left by # of bits processed according to BCM2711 Peripherals documentation
	ldr r6, =3	@ load r6 w/ 0b11
	lsl r6, r6, r5	@ shift bit clear mask over to correct position
	mvn r6, r6 	@ Not bit clear mask
	and r4, r4, r6	@ use clear mask to clear bits of interest
	orr r4, r4, r1	@ or value with cleared bits with bits of interest
	str r4, [r3] 	@ Store bits in given address
	
	@ Load link reg
	POP {r2-r9,LR}
	bx LR

error:
	@ ERROR MESSAGE HERE
	ldr r0, =msg
	bl printf
	POP {r2-r9,LR}
	bx LR

GPIO_BASE:
    .word   0xfe200000  @GPIO Base address Raspberry pi 4
mem_fd:
    .word   device
O_RDWR_O_SYNC:
    .word   2|256       @ O_RDWR (2)|O_SYNC (256).
