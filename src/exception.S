#define TRAP_FRAM_SIZE 272 ;(x0-x30) + SP_EL0 + ESR + ELR 
#define TF_X0       0 
#define TF_X1       8 
#define TF_X29      232 
#define TF_X30      240 
#define TF_SP_EL0   248 
#define TF_ESR      256 
#define TF_ELR      264 

.macro save_trap_frame 
    sub     sp, sp  TRAP_FRAM_SIZE

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
    msr     x23, elr_el1 

    stp     x22, x23, [sp, #TF_ESR]
.endm 

