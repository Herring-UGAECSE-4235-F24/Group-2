@ GPIO22 Related
@.equ    GPFSEL2, 0x08   @ function register offset
.equ    GPCLR0, 0x28    @ clear register offset
.equ    GPSET0, 0x1c    @ set register offset
.equ    GPLEV0, 0x34    @ set register offset
@.equ    GPFSEL2_GPIO22_MASK, 0b000111000   @ Mask for fn register (bit 7-6)
@.equ    MAKE_GPIO22_OUTPUT, 0x08     @ use pin for output (bit 7)
@.equ    PIN, 21                         @ Used to set PIN high / low

@ Args for mmap
.equ    OFFSET_FILE_DESCRP, 0   @ file descriptor
.equ    mem_fd_open, 3
.equ    BLOCK_SIZE, 4096        @ Raspbian memory page
.equ    ADDRESS_ARG, 3          @ device address

@ The following are defined in /usr/include/asm-generic/mman-common.h:
.equ    MAP_SHARED, 1    @ share changes with other processes
.equ    PROT_RDWR, 0x3   @ PROT_READ(0x1)|PROT_WRITE(0x2)

@ Constant program data
.section .rodata
device:
    .asciz  "/dev/gpiomem"

.text
.global gPIOwrite
gPIOwrite:
    push {lr}
    push {r0-r12}
    ldr r2, =SP_BLOCK
    str sp, [r2]
    mov  r7, r0
    mov r9, r1

@ Open /dev/gpiomem for read/write and syncing
    ldr     r1, O_RDWR_O_SYNC   @ flags for accessing device
    ldr     r0, mem_fd         @ address of /dev/gpiomem
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
    mov     r5, r0           @ save the virtual memory address in r5

    mov r8, r7                       @r8 holds number of shifts to perform
    mov r3, #-4                             @r3 is GPFSEL offset register
@Find number of shifts, in r8, change gpfsel register r3 to appropriate offset value
findShifts:
    add r3, r3, #4
    subs r8, r8, #10
    bpl findShifts
    add r8, r8, #10

@Set mask register r11 and pin activator register r6
    mov r11, #0x7
    mov r6, #0x1

@Shift mask register r11 and pin activator register r6
    lsl r11, r11, r8 @shifts r11 left by r8 positions
    lsl r11, r11, r8 @shifts r11 left by r8 positions
    lsl r11, r11, r8 @shifts r11 left by r8 positions

    lsl r6, r6, r8 @shifts r6 left by r8 positions
    lsl r6, r6, r8 @shifts r6 left by r8 positions
    lsl r6, r6, r8 @shifts r6 left by r8 positions

@ Set up the GPIO pin function register in programming memory
    add     r0, r5, r3                  @#GPFSEL2            @ calculate address for GPFSEL2
    ldr     r2, [r0]                    @ get entire GPFSEL2 register
    bic     r2, r2, r11                 @#GPFSEL2_GPIO22_MASK@ clear pin field for GPIO22
    orr     r2, r2, r6                  @#MAKE_GPIO22_OUTPUT @ enter function code for GPIO22
    str     r2, [r0]                    @ update register

    mov r10, #1
    cmp r10, r9
    bne off
    
on:
    @ Turn GPIO22 on 
    add     r0, r5, #GPSET0 @ calc GPSET0 address

    mov     r3, #1          @ turns on bit
    lsl     r3, r3, r7   @ shift bit to pin position
    orr     r2, r2, r3      @ sets bit
    str     r2, [r0]        @ update register

    b end

off:
    @Turn GPIO22 off
    add     r0, r5, #GPCLR0 @ calc GPSET0 address

    mov     r3, #1          @ turns off bit
    lsl     r3, r3, r7    @ shift bit to pin position
    orr     r2, r2, r3      @ sets bit
    str     r2, [r0]        @ update register

end:
    mov r0, #0
    ldr r12, =SP_BLOCK
    ldr sp, [r12] 
    pop {r0-r12}
    pop {lr}
    bx lr

GPIO_BASE:
    .word   0xfe200000  @ GPIO Base address Raspberry Pi 4
mem_fd:
    .word   device
O_RDWR_O_SYNC:
    .word   2|256       @ O_RDWR (2)|O_SYNC (256)
.data
SP_BLOCK:
    .word 0
