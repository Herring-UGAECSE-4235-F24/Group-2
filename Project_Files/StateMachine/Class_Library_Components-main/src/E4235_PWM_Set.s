@ mmap part taken from by https://bob.cs.sonoma.edu/IntroCompOrg-RPi/sec-gpio-mem.html

    .equ    GPFSEL1, 0x04   @ function register offset
    .equ    GPFSEL1_GPIO12, 0x100       @ GPIO12 ALT0
    .equ    GPFSEL1_GPIO13, 0x800       @ GPIO13 ALT0
    .equ    GPFSEL1_GPIO18, 0x2000000   @ GPIO18 ALT5
    .equ    GPFSEL1_GPIO19, 0x10000000  @ GPIO19 ALT5

    .equ PWMCTRL, 0x00      @ CTRL register offset
    .equ PWMRNG1, 0x10      @ RNG1 register offset
    .equ PWMDATA1, 0x14     @ DAT1 register offset
    .equ PWMRNG2, 0x20      @ RNG2 register offset
    .equ PWMDATA2, 0x24     @ DAT2 register offset

    @ Args for mmap
    .equ    OFFSET_FILE_DESCRP, 0   @ file descriptor
    .equ    mem_fd_open, 3
    .equ    BLOCK_SIZE, 4096        @ Raspbian memory page
    .equ    ADDRESS_ARG, 3          @ device address

    @ The following are defined in /usr/include/asm-generic/mman-common.h:
    .equ    MAP_SHARED,1    @ share changes with other processes
    .equ    PROT_RDWR,0x3   @ PROT_READ(0x1)|PROT_WRITE(0x2)

    GPIO .req r6
    FREQ .req r7
    DUTY .req r8

@ Constant program data
    .section .rodata
device:
    .asciz  "/dev/mem"

@ The program
    .text
    .cpu cortex-a7
    .global E4235_PWM_Set

E4235_PWM_Set:
    push    {lr}
    push    {r3-r9}
    mov     GPIO, r0    @ saves GPIO number
    mov     FREQ, r1    @ saves frequency number
    mov     DUTY, r2    @ saves duty cycle number

checkInputs:
    cmp     FREQ, #0    @ frequency > 0
    movle   r0, #2      @ error code 2
    ble     quit

    cmp     DUTY, #100  @ 0 < duty cycle < 100
    movge   r0, #3      @ error code 3
    bge     quit
    cmp     DUTY, #0
    movle   r0, #3
    ble     quit

    @ checks if GPIO is a valid input
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

GPIO_SET:
@ Map the GPIO registers to a main memory location so we can access them
    mov     r1, #BLOCK_SIZE             @ r1=get 1 page of memory
    mov     r2, #PROT_RDWR              @ r2=read/write this memory
    mov     r3, #MAP_SHARED             @ r3=share with other processes
    mov     r0, #0                      @ NULL address - compiler chooses virtual map
    ldr     r5, GPIO_BASE               @ address of GPIO
    str     r5, [sp, #4]                @ 5th argument = offset address
    bl      mmap
    mov     r5, r0                      @ save the virtual memory address in r5

@ Set up the GPIO pin funtion register in programming memory
    add     r0, r5, #GPFSEL1            @ calculate address for GPFSEL1
    ldr     r2, [r0]                    @ get entire GPFSEL1 register

    @ choose GPIO alternate function
    cmp     GPIO, #12
    orreq   r2, r2, #GPFSEL1_GPIO12
    cmp     GPIO, #13
    orreq   r2, r2, #GPFSEL1_GPIO13
    cmp     GPIO, #18
    orreq   r2, r2, #GPFSEL1_GPIO18
    cmp     GPIO, #19
    orreq   r2, r2, #GPFSEL1_GPIO19

    str     r2, [r0]                    @ set GPIO alternate function

PWM_SET:
    mov     r1, #BLOCK_SIZE             @ r1=get 1 page of memory
    mov     r2, #PROT_RDWR              @ r2=read/write this memory
    mov     r3, #MAP_SHARED             @ r3=share with other processes
    mov     r0, #0                      @ address of /dev/mem
    ldr     r5, PWM_BASE                @ address of PWM
    str     r5, [sp, #4]                @ 5th argument = offset address
    bl      mmap
    mov     r5, r0                      @ save the virtual memory address in r5

    @ sets up PWM Range register
    cmp     GPIO, #12
    addeq   r0, r5, #PWMRNG1
    cmp     GPIO, #13
    addeq   r0, r5, #PWMRNG2
    cmp     GPIO, #18
    addeq   r0, r5, #PWMRNG1
    cmp     GPIO, #19
    addeq   r0, r5, #PWMRNG2

    @ range = 375MHz/freq
    ldr     r2, [r0]
    ldr     r1, =#375000000
    udiv    r2, r1, FREQ
    mov     r9, r2
    str     r2, [r0]    @ stores range for PWM

    @ sets up PWM Data register
    cmp     GPIO, #12
    addeq   r0, r5, #PWMDATA1
    cmp     GPIO, #13
    addeq   r0, r5, #PWMDATA2
    cmp     GPIO, #18
    addeq   r0, r5, #PWMDATA1
    cmp     GPIO, #19
    addeq   r0, r5, #PWMDATA2

    @ data = duty*range/100
    ldr     r2, [r0]
    ldr     r1, =#100
    mul     r2, DUTY, r9
    udiv    r2, r2, r1
    str     r2, [r0]    @ stores data for PWM

    mov     r0, #0      @ successful set

quit:
    pop {r3-r9}
    pop {lr}
    bx lr

GPIO_BASE:
    .word   0xfe200000  @GPIO Base address Raspberry pi 4
PWM_BASE:
    .word   0xfe20c000  @PWM0 Base Address RP4
mem_fd:
    .word   device
O_RDWR_O_SYNC:
    .word   2|256       @ O_RDWR (2)|O_SYNC (256).
