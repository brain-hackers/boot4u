.text
    .align 4
    .global _start

_start:
//M4 RTOS loader snipet prep
    ldr r4, =0x60006400 //fopen addr
    adr r0, [.LC2] //file name
    adr r1, [.LC1] //open mode
    blx r4
    add r5, r4, #0xc //fread addr
    mov r3, r0 //file descriptor
    ldr r0, =0x1ffe4000 //fread destination
    mov r1, #1 //read unit size
    mov r2, r0 //read unit count(over size)
    blx r5

//M4 RTOS preload
    ldr r4, =0x60006400 //fopen addr
    adr r0, [.LC3] //file name
    adr r1, [.LC1] //open mode
    blx r4
    add r5, r4, #0xc //fread addr
    mov r3, r0 //file descriptor
    ldr r0, =0x37400000 //fread destination
    mov r1, #1 //read unit size
    mov r2, r0 //read unit count(over size)
    blx r5

//M4 RTOS size get
    ldr r4, =0x60006444 //stat addr
    adr r0, [.LC3] //file name
    sub sp, sp, #0x14
    mov r1, sp
    blx r4
    ldr r0, =0x373ffffc //store size before data
    ldr r1, [sp,#0x10]
    str r1, [r0]

//M4 interrupt prep
    ldr r4, =0x1ffd20d0 //NVIC MCM vector
    ldr r5, =0x1ffe4001 //loader addr | 0x1(thumb)
    str r5, [r4] //override interrupt handler
    
//wait until M4 RTOS copied
    ldr r4, =0x1ffd2000 //get sram img start addr
    add r0, r0, #4 //get dram rtos addr
    ldr r3, [r0, r1] //get last word of rtos on dram
rtos_loop:
    ldr r2, [r4,r1] //get last word of rtos on sram
    cmp r2,r3
    bne rtos_loop

//preload U-Boot from sd
    ldr r4, =0x60006400 //fopen addr
    adr r0, [.LC0] //file name
    adr r1, [.LC1] //open mode
    blx r4
    add r5, r4, #0xc //fread addr
    mov r3, r0 //file descriptor
    ldr r0, =0x37500000 //fread destination
    mov r1, #1 //read unit size
    mov r2, r0 //read unit count(over size)
    blx r5
    bl continue //to avoid strings address exceeds pc relative offset limit

    .LC0:
    .ascii  "SD0:\\u-boot.bin\000"
    .LC1:
    .ascii  "r\000"
    .LC2:
    .ascii  "SD0:\\m4_loader.bin\000"
    .LC3:
    .ascii  "SD0:\\m4_rtos.bin\000"
.align 4
    continue:
    cpsid if //disable interrupt

//copy U-Boot to head of RAM 
    ldr r3, =0x37500000 //copy start
    add r1, r3, r0 //copy end
    copy_loop:
    mov r2, r3
    sub r3, r3, #0x7500000 //copy distination
    ldr r0, [r2], #4
    cmp r2, r1
    str r0, [r3]
    mov r3, r2
    blt copy_loop

//RAM clear
    ldr r2,=0x60200000 //clear start
    ldr r3,=0x68000000 //clear end
    sub r3,r3,#4
    eor r1,r1,r1
    clear_loop:
    cmp r2,r3
    str r1,[r2],#4
    beq clear_loop

    ldr r0, =0x60000000

    mrc p15, 0, r8, c14, c2, 1
    bic r8, r8, #1
    mcr p15, 0, r8, c14, c2, 1
    mrc p15, 0, r8, c14, c3, 1
    bic r8, r8, #1
    mcr p15, 0, r8, c14, c3, 1

    mov r9, #0
    mrc p15, 0, r6, c1, c0, 0
    bic r6, r6, #4  @ disable dcache
    bic r6, r6, #4096  @ disable icache
    mcr p15, 0, r6, c1, c0, 0 // write ctrl regs

    mcr p15, 0, r9, c7, c5, 0 // invalidate icache

    // from: https://www.aps-web.jp/academy/ca/229/#i-2
    mov  r10,#0                 // データキャッシュを選択
    mcr  p15,2,r10,c0,c0,0      // キャッシュサイズ選択レジスタ（CSSELR）で
							    // データキャッシュを選択
    isb                         // 命令同期バリア命令で再フェッチ
    mrc  p15,1,r1,c0,c0,0       // CCSIDRを読み込み
    and  r2,r1,#7               // キャッシュラインサイズを取得（b001=8ワード/ライン）
    add  r2,r2,#4               // DCISWレジスタのセット番号のシフト数を求める
    ldr  r4,=0x3FF              // 最大ウェイ数マスク設定値を設定
    ands r4,r4,r1,LSR #3        // r4レジスタにウェイ数を設定
    clz  r5,r4                  // DCISWレジスタのウェイ番号のシフト数を求める
    ldr  r7,=0x7FFF             // セット数マスク設定値を設定
    ands r7,r7,r1,LSR #13       // r7レジスタにセット数を設定
							  // 0x7F=12Kbyte/0xFF=32Kbyte/0x1FF=64Kbyte
    loop2:
    mov  r9,r4                  // r9レジスタにウェイ数を設定
    loop3:
    orr  r11,r10,r9,LSL r5      // ウェイ番号とキャッシュ番号を設定
    orr  r11,r11,r7,LSL r2      // セット番号を設定
    mcr  p15,0,r11,c7,c6,2      // DCISWレジスタでセット/ウェイによる
							    // データキャッシュラインの無効化
    subs r9,r9,#1               // ウェイ番号を-1
    bge  loop3                  // ウェイ毎の初期化を実施
    subs r7,r7,#1               // セット番号を-1
    bge  loop2                  // セット毎の初期化を実施

    mcr p15, 0, r9, c8, c7, 0 // invalidate TLB
    mcr p15, 0, r9, c7, c5, 6 // invalidate branch predictor array

    bic r6, r6, #1  @ disable MMU
    mcr p15, 0, r6, c1, c0, 0 // write ctrl regs

    bx r0

