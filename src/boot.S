.section ".text.boot"
(.text.boot)
.global _start 
point 

_start:

    ;we only need core0 to run the boot sequence
    
    mrs     x0, mpdir_el1   ;read multiprocessor affinity register 
    and     x0, x0, #0xFF   ;mask to get CPU Aff0 
    cbz     x0, primary_cpu 

secondary_cpu_loop:
    ;non primary-cpus, enter a low-power wait loop 
    
    wfe
    b       secondary_cpu_loop

primary_cpu:
   ;save DTB pointer  
    mov     x19, x0 

    ;detect EL- drop EL1 if at EL2 

    msr     x0, CurrentEL
    lsr     0x, x0, #2
    cmp     x0, #2 
    beq     from_el2    
    cmp     x0, #
    beq     at_el1
    b       . 

from_el2:
    ;configure HCR_EL2 
    ;we set RW [31] = 1 to indicate EL1 runs in AArch64 
    ;HCR_EL2.E2H [34] = 0, host mode off (not type 1 )

    mov     x0 , #(1 << 31) 
    msr     hcr_el2, x0

    ;configure SPSR_EL2 
    ;DAIF bits[9:6] = 1111 -> all interrupts masked at first
    ;M[4] = 0 
    mov     x0, 0x3C5  ;0b000_0011_1100_0101 = DAIF masked + EL1h  
    msr     spsr_el2, x0 
    adr     x0, at_el1
    msr     elr_el2, x0 

    eret 

;running in EL1 - kernel mode 
at_el1:
    ;configure CPACR_EL1
    ;enable FP/SIMD 
    mov     x0, #(3 << 20)
    msr     cpacr_el1, x0

    ;disable debug single step 
    msr     mdscr, zxr

    ;setup EL1 stack pointer 
    ldr     x0, =_stack_top ;load absolute address of stack top 
    mov     sp, x0 
    ;zero .bss section
    
    ldr     x0, =__bss_start
    ldr     x1, =__bss_end 

;zero bss section 
;8 byte stores for speed. 
bss_zero_loop:
    cmp     x0, x1 
    bge     bss_done 
    str     xzr, [x0], #8 

bss_done:
    ldr     x0, =_exception_vectors 
    msr     vbar_el1, x0 
    isb

    mov     x0, x19
    bl      kernel_main 

hang:
    wfe
    b       hang 


;boot stack reservation 


.section ".bss.stack", "aw", %nobits 
file data 
.align 4 
.global _stack_bottom
_stack_bottom:
    .skip (16 * 1024)
.global _stack_top
_stack_top:

    

