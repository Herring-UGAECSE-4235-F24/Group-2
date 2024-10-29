
    @ Args for mmap
    .equ    OFFSET_FILE_DESCRP, 0   @ file descriptor
    .equ    mem_fd_open, 3
    .equ    BLOCK_SIZE, 4096        @ Raspbian memory page
    .equ    ADDRESS_ARG, 3          @ device address

    @ The following are defined in /usr/include/asm-generic/mman-common.h:
    .equ    MAP_SHARED,1    @ share changes with other processes
    .equ    PROT_RDWR,0x3   @ PROT_READ(0x1)|PROT_WRITE(0x2)


    .equ PASSWRD, 0x5a000000      @ CLK Manager Password
    .equ CLK_PWMCTL, 0xa0   @ PWMCTL register offset
    .equ CLK_PWMDIV, 0xa4   @ PWMDIV register offset
    .equ PWMCTRL, 0x00      @ CTRL register offset


    GPIO    .req r6
    EN      .req r7

    .section .rodata
device:
    .asciz "/dev/mem"

    .text
    .global E4235_PWM_Enable

E4235_PWM_Enable:
    push {lr}
    push {r1-r7}
    mov     GPIO, r0
    mov     EN, r1

checkInputs:
    @ Checks that EN is 0 or greater
    cmp     EN, #0      @ EN not negative
    movlt   r0, #2      @ error code 2
    blt     quit

    @ Checks if GPIO is a valid input
    cmp     GPIO, #12
    beq     OPEN_DEV_MEM
    cmp     GPIO, #13
    beq     OPEN_DEV_MEM
    cmp     GPIO, #18
    beq     OPEN_DEV_MEM
    cmp     GPIO, #19
    beq     OPEN_DEV_MEM
    mov     r0, #1      @ error code 1
    b       quit

OPEN_DEV_MEM:
@ Open /dev/mem for read/write and syncing
    ldr     r1, O_RDWR_O_SYNC               @ flags for accessing device
    ldr     r0, mem_fd                      @ address of /dev/mem
    bl      open
    mov     r4, r0                          @ use r4 for file descriptor
    str     r4, [sp, #OFFSET_FILE_DESCRP]   @ r4=/dev/mem file descriptor

@ Starts clock fo PWM
CLK_SET:
    mov     r1, #BLOCK_SIZE             @ r1=get 1 page of memory
    mov     r2, #PROT_RDWR              @ r2=read/write this memory
    mov     r3, #MAP_SHARED             @ r3=share with other processes
    mov     r0, #0                      @ address of /dev/mem
    ldr     r5, CLK_BASE                @ address of CLK
    str     r5, [sp, #4]                @ 5th argument = offset address
    bl      mmap
    mov     r5, r0                      @ save the virtual memory address in r5

    @ clock master setup
    add     r0, r5, #CLK_PWMCTL         @ address for CLK_PWMCTL
    ldr     r2, [r0]                    @ load contents into r2
    ldr     r2, =#0x96
    orr     r2, r2, #PASSWRD
    str     r2, [r0]

    @ clock divider set up
    add     r0, r5, #CLK_PWMDIV         @ address for CLK_PWMDIV
    ldr     r2, [r0]                    @ load contents into r2
    ldr     r2, =#0x2000
    orr     r2, r2, #PASSWRD
    str     r2, [r0]

PWM_SET:
    mov     r1, #BLOCK_SIZE             @ r1=get 1 page of memory
    mov     r2, #PROT_RDWR              @ r2=read/write this memory
    mov     r3, #MAP_SHARED             @ r3=share with other processes
    mov     r0, #0                      @ address of /dev/mem
    ldr     r5, PWM_BASE                @ address of PWM
    str     r5, [sp, #4]                @ 5th argument = offset address
    bl      mmap
    mov     r5, r0                      @ save the virtual memory address in r5

    @ sets up PWM Control register and enables PWM
    add     r0, r5, #PWMCTRL
    ldr     r2, [r0]

    @ chooses between enable/disable
    cmp EN, #0
    beq DISABLE_PWM

ENABLE_PWM:
    @ 0x81 = MS_Mode_EN and PWM_EN
    mov     r3, #0xff        @ value to clear PWM bits
    cmp     GPIO, #12
    biceq   r2, r2, r3
    orreq   r2, r2, #0x81   @ PWM_0 -> bits 7:0
    cmp     GPIO, #13
    bic     r2, r2, r3, lsl #8
    moveq   r3, #0x8100      @ PWM_1 -> bits 15:0
    orreq   r2, r2, r3
    cmp     GPIO, #18
    biceq   r2, r2, r3
    orreq   r2, r2, #0x81   @ PWM_0 -> bits 7:0
    cmp     GPIO, #19
    biceq   r2, r2, r3, lsl #8
    moveq   r3, #0x8100      @ PWM_1 -> bits 15:0
    orreq   r2, r2, r3

    str     r2, [r0]        @ saves PWM CTL Register
    mov r0, #0              @ successful enable
    b quit

DISABLE_PWM:
    cmp     GPIO, #12
    biceq   r2, r2, #0x1    @ PWM_EN_0 -> 0
    cmp     GPIO, #13
    biceq   r2, r2, #0x100  @ PWM_EN_1 -> 0
    cmp     GPIO, #18
    biceq   r2, r2, #0x1    @ PWM_EN_0 -> 0
    cmp     GPIO, #19
    biceq   r2, r2, #0x100  @ PWM_EN_1 -> 0

    str     r2, [r0]        @ saves PWM CTL Register
    mov r0, #0              @ successful disable

quit:
    pop {r1-r7}
    pop {lr}
    bx lr

CLK_BASE:
    .word   0xfe101000
PWM_BASE:
    .word   0xfe20c000  @PWM0 Base Address RP4
mem_fd:
    .word   device
O_RDWR_O_SYNC:
    .word   2|256       @ O_RDWR (2)|O_SYNC (256).
