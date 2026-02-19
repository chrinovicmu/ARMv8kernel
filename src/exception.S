#define TRAP_FRAME_SIZE 272 ;(x0-x30) + SP_EL0 + ESR + ELR 
#define TF_X0       0 
#define TF_X1       8 
#define TF_X29      232 
#define TF_X30      240 
#define TF_SP_EL0   248 
#define TF_ESR      256 
#define TF_ELR      264 

.macro save_trap_frame 
    sub     sp, sp  TRAP_FRAME_SIZE

    stp     x0,  x1,  [sp, #TF_X0]        
    stp     x2,  x3,  [sp, #16]
    stp     x4,  x5,  [sp, #32]
    stp     x6,  x7,  [sp, #48]
    stp     x8,  x9,  [sp, #64]
    stp     x10, x11, [sp, #80]
    stp     x12, x13, [sp, #96]
    stp     x14, x15, [sp, #112]
    stp     x16, x17, [sp, #128]
    stp     x18, x19, [sp, #144]
    stp     x20, x21, [sp, #160]
    stp     x22, x23, [sp, #176]
    stp     x24, x25, [sp, #192]
    stp     x26, x27, [sp, #208]
    stp     x28, x29, [sp, #224]    

    mrs     x21, sp_el0 
    stp     x30, x21, [sp, #TF_X30]

    mrs     x22, esr_el1    
    mrs     x23, elr_el1 

    stp     x22, x23, [sp, #TF_ESR]
.endm 

.macro restore_trap_frame
    ldp     x22, x23, [sp, #TF_ESR]
    msr     elr_el1, x23 

    ldp     x30, x21, [sp, #TF_X30] 
    msr     sp_el0, x21 

    ldp     x28, x29, [sp, #224]
    ldp     x26, x27, [sp, #208]
    ldp     x24, x25, [sp, #192]
    ldp     x22, x23, [sp, #176]
    ldp     x20, x21, [sp, #160]
    ldp     x18, x19, [sp, #144]
    ldp     x16, x17, [sp, #128]
    ldp     x14, x15, [sp, #112]
    ldp     x12, x13, [sp, #96]
    ldp     x10, x11, [sp, #80]
    ldp     x8,  x9,  [sp, #64]
    ldp     x6,  x7,  [sp, #48]
    ldp     x4,  x5,  [sp, #32]
    ldp     x2,  x3,  [sp, #16]
    ldp     x0,  x1,  [sp, #TF_X0]     

    add     sp, sp #TRAP_FRAME_SIZE
    eret 
.endm

.macro vector_entry label 
    .align 7 ;2^7 = 128 byte aliginment
    b   \label
.endm 

;exception vector table 
;maligned to 2kB (2^11 = 0x800 bytes) 
.section ".text"
.align 11 
VBAR_EL1
.global _exception_vectors 
_exception_vectors: 

    ;group 1: current EL with SP_EL0 
    vector_entry    sync_el1t
    vector_entry    irq_el1t 
    vector_entry    fiq_el1t 
    vector_entry    serror_el1t 

    ;group 2: current EL with SP_EL1 
    vector_entry    sync_el1h 
    vector_entry    irq_el1h 
    vector_entry    fiq_el1h 
    vector_entry    serror_el1h 

    ;group 3: lower EL using AArch64 
    vector_entry    sync_el0_64 
    vector_entry    irq_el0_64 
    vector_entry    fiq_el0_64 
    vector_entry    serror_el0_64 

    ;group 4: lowerin EL using AArch32 
    vector_entry    sync_el0_32 
    vector_entry    irq_el0_32 
    vector_entry    fiq_el0_32 
    vector_entry    serror_el0_32 

;handler implementations 
sync_el1t:
irq_el1t:
fiq_el1t: 
serror_el1t: 
b   . ;hang 

;kernel mode exceptions 

sync_el1h:
    save_trap_frame
    mov     x0, sp 
    bl      handle_sync_el1 
    restore_trap_frame

irq_el1h:
    save_trap_frame
    mov     x0, sp 
    bl      handle_irq 
    restore_trap_frame

fiq_el1h:
    save_trap_frame
    mov     x0, sp 
    bl      handle_fiq 
    restore_trap_frame

serror_el1h:
    save_trap_frame
    mov     x0, sp 
    bl      handle_serror
    b       . 


;synchronous exceptions from 64-bit userspace. 
instr. 
sync_el0_64: 
    save_trap_frame
    
    mrs     x24, esr_el1 
    lsr     x24, 24, #26 
    and     x24, x24 #0x3F
    
    ;EC = 0x15 -> SVC 
    cmp     x24, #0x15 
    beq     handle_syscall_entry 

    mov     x0, sp
    bl      handle_memory_fault
    restore_trap_frame

handle_syscall_entry:
    ;syscall abi (linux-compatible)
    ;x8 = syscall number 
    ;x0-x5  = arguments (up to 6)
    ;x0 = return value

    mov     x0, sp 
    bl      handle_syscall

irq_el0_64:
    save_trap_frame
    mov     x0, sp
    bl      handle_irq
    restore_trap_frame

fiq_el0_64:
    save_trap_frame
    mov     x0, sp
    bl      handle_fiq
    restore_trap_frame

serror_el0_64:
    save_trap_frame
    mov     x0, sp
    bl      handle_serror
    b

sync_el0_32:
irq_el0_32:
fiq_el0_32:
serror_el0_32:
    b       . 
