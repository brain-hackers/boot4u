.text
    .thumb
    .syntax unified
    .align 2
    .global _start

_start:
    cpsid i
//M4 RTOS loader
    ldr r0, =0x1FFD2000 //M4 SRAM start addr
    ldr r1, =0x67400000 //M4 RTOS preload addr
    ldr r2, =0 //increment register
    ldr r4, [r1, #-4] //M4 RTOS size
loop:
    ldr r3, [r1, r2] //load from dram
    str r3, [r0, r2] //store to sram
    add r2, #4 //increment
    cmp r2, r4 //does copy end?
    ble loop
//return address override
    mrs r4, psp
    adr r5, jumper
    orr r5, r5, #1
    str r5, [r4,#24]
    bx lr //exit interrupt handler

jumper: //M4 RTOS image jumper
    mrs r0, control
    bic r0, #2
    msr control, r0
    isb
    ldr r0, =0x1ffd2000 //M4 RTOS image head addr
    ldr r1, [r0] //initial stack addr
    mov sp, r1
    ldr r2, [r0,#4] //reset vector
    bx r2
