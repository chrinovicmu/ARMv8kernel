#ifndef VMM_H
#define VMM_H 

#incude "types.h"

#define PAGE_SIZE       4096UL 
#define PAGE_SHIFT      12 
#define PAGE_MASK       (~(PAGE_SIZE -1))

#define PTRS_PER_TABLE  512 
#define TABLE_SIZE      (PTRS_PER_TABLE * sizeof(uint64_t))

/*bits[1:0] descriptor type */ 
#define PTE_TYPE_MASK   0x3ULL 
#define PTE_TYPE_FAULT  0x0ULL 
#define PTE_TYPE_BLOCK  0x1ULL 
#define PTE_TYPE_TABLE  0x3ULL 
#define PTE_TYPE_PAGE   0x3ULL 

/*bit[10] - access flag */ 
#define PTE_AF          (1ULL << 10)

/*bits[9:8] - shareability */ 
#define PTE_SH_NS       (0ULL << 8)
#define PTE_SH_OS       (2ULL << 8)
#define PTE_SH_IN       (3ULL << 8)

/* Bits [7:6] - Access Permissions (AP) */
/* EL1 (kernel) read/write, EL0 (user) no access */
#define PTE_AP_EL1_RW_EL0_NONE   (0ULL << 6)  
/* EL1 read/write, EL0 read-only */
#define PTE_AP_EL1_RW_EL0_RO     (1ULL << 6)  
/* EL1 read-only, EL0 no access */
#define PTE_AP_EL1_RO_EL0_NONE   (2ULL << 6)  
/* EL1 read-only, EL0 read-only */
#define PTE_AP_EL1_RO_EL0_RO     (3ULL << 6) 

/*bit [54] - never execute at EL1*/
#define PTE_PXN                 (1ULL << 54)
/*bit [53] - never execute at EL0*/  
#define PTE_UXN                 (1ULL << 53)

#define PTE_ATTRINDX            ((n) << 2)
#define MAIR_IDX_NORMAL         0 
#define MAIR_IDX_DEVICE         1 
#define MAIR_IDX_NC             2 

/*MAIR encoding */ 
#define MAIR_NORMAL_ATTR        0xFFULL //0b1111111
#define MAIR_DEVICE_ATTR        0x44ULL //0b0000000
#define MAIR_NC_ATTR            0x44ULL //0b1000100

#define MAIR_EL1_VALUE          ((MAIR_NORMAL_ATTR << (MAIR_IDX_NORMAL * 8)) | \
                                 (MAIR_DEVICE_ATTR << (MAIR_IDX_DEVICE * 8)) | \ 
                                 (MAIR_NC_ATTR  << (MAIR_IDX_NC * 8)))

/*VA size offset
 * va = 2^(64 - TxSZ)*/ 
#define TCR_T0SZ                (16ULL << 0)
#define TCR_T1SZ                (16ULL << 16)

#define TCR_TG0_4K              (0ULL << 14)
#define TCR_TG1_4K              (2ULL << 30)

/*cacheability attributes */ 
#define TCR_IRGN0_WBWA          (1ULL << 8)
#define TCR_IRGN1_WBWA          (1ULL << 24)
#define TCR_ORGN0_WBWA          (1ULL << 10) 
#define TCR_ORGN1_WBWA          (1ULL << 26)

/*shareability of page walks 
 * set as inner shareable*/ 
#define TCR_SH0_INNER           (3ULL << 12) 
#define TCR_SH1_INNER           (3ULL << 28) 

/*intermediaet physical address size */ 
#define TCR_IPS_40BIT           (2ULL << 32) 

#define TCR_EPD0_ENABLE         (0ULL << 7)
#define TCR_EPD1_ENABLE         (0ULL << 23)

#define TCR_EL1_VALUE       (TCR_T0SZ | TCR_T1SZ | \
                            TCR_TG0_4K | TCR_TG1_4K | \
                            TCR_IRGN0_WBWA | TCR_IRGN1_WBWA | \
                            TCR_ORGN0_WBWA | TCR_ORGN1_WBWA | \
                            TCR_SH0_INNER  | TCR_SH1_INNER  | \
                            TCR_IPS_40BIT)

/*system control register*/ 
#define SCTLR_M             (1ULL << 0)   // MMU enable — the main switch
#define SCTLR_C             (1ULL << 2)   // Data cache enable
#define SCTLR_I             (1ULL << 12)  // Instruction cache enable
#define SCTLR_SA            (1ULL << 3)   // Stack alignment check (EL1)
#define SCTLR_SA0           (1ULL << 4)   // Stack alignment check (EL0)

#define KERNEL_VA_START         0xFFFF000000000000ULL   
#define KERNEL_VA_END           0xFFFFFFFFFFFFFFFFULL
#define USER_VA_START           0x0000000000000000ULL   
#define USER_VA_END             0x0000FFFFFFFFFFFFULL

#define PHYS_MEMORY_START       0x40000000ULL   // 1GB mark
#define PHYS_MEMORY_SIZE        (256 * 1024 * 1024ULL)  // 256MB of RAM
#define PHYS_MEMORY_END         (PHYS_MEMORY_START + PHYS_MEMORY_SIZE)

#define PAGE_ALIGN_UP(addr)     (((addr) + PAGE_SIZE - 1) & PAGE_MASK)
#define PAGE_ALIGN_DOWN(addr)   ((addr) & PAGE_MASK)
#define PA_TO_PFN(pa)           ((pa) >> PAGE_SHIFT)
#define PFN_TO_PA(pfn)          ((pfn) << PAGE_SHIFT)



#endif //
