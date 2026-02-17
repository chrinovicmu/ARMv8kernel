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

