/**
 * MMU与分布处理
 */
#ifndef MMU_H
#define MMU_H

#include "comm/types.h"
#include "comm/cpu_instr.h"

#define PDE_CNT     1024
#define PTE_CNT     1024
#define PTE_P       (1 << 0)
#define PTE_W       (1 << 1)
#define PDE_P       (1 << 0)
#define PTE_U       (1 << 2)
#define PDE_U       (1 << 2)

#pragma pack(1)
/**
 * @brief 定义了一个名为 pde_t 的联合体（union），用于表示 x86 架构中分页机制的页目录项（Page Directory Entry，PDE）
 */
typedef union _pde_t {
    uint32_t v;
    struct {
        uint32_t present : 1;                   // 0 (P) Present; must be 1 to map a 4-KByte page
        uint32_t write_disable : 1;             // 1 (R/W) Read/write, if 0, writes may not be allowe
        uint32_t user_mode_acc : 1;             // 2 (U/S) if 0, user-mode accesses are not allowed t
        uint32_t write_through : 1;             // 3 (PWT) Page-level write-through
        uint32_t cache_disable : 1;             // 4 (PCD) Page-level cache disable
        uint32_t accessed : 1;                  // 5 (A) Accessed
        uint32_t : 1;                           // 6 Ignored;
        uint32_t ps : 1;                        // 7 (PS)
        uint32_t : 4;                           // 11:8 Ignored
        uint32_t phy_pt_addr : 20;              // 高20位page table物理地址
    };
}pde_t;

/**
 * @brief 定义了一个名为 pte_t 的联合体（union），用于表示 x86 架构中分页机制的页表项（Page Table Entry，PTE）
 */
typedef union _pte_t {
    uint32_t v;
    struct {
        uint32_t present : 1;                   // 0 (P) Present; must be 1 to map a 4-KByte page
        uint32_t write_disable : 1;             // 1 (R/W) Read/write, if 0, writes may not be allowe
        uint32_t user_mode_acc : 1;             // 2 (U/S) if 0, user-mode accesses are not allowed t
        uint32_t write_through : 1;             // 3 (PWT) Page-level write-through
        uint32_t cache_disable : 1;             // 4 (PCD) Page-level cache disable
        uint32_t accessed : 1;                  // 5 (A) Accessed;
        uint32_t dirty : 1;                     // 6 (D) Dirty
        uint32_t pat : 1;                       // 7 PAT
        uint32_t global : 1;                    // 8 (G) Global
        uint32_t : 3;                           // Ignored
        uint32_t phy_page_addr : 20;            // 高20位物理地址
    };
}pte_t;


/**
 * @brief C/C++ 中的一个预编译指令，用于控制结构体、联合体等数据类型的成员在内存中的对齐方式
 * 在默认情况下，编译器会按照自然对齐规则（通常是成员大小的整数倍）排列结构体成员
 * #pragma pack() 的作用是强制改变这种对齐方式，可以指定更小的对齐单位，减少内存占用，或保证在不同平台 / 编译器下结构体的内存布局一致
 */
#pragma pack()


/**
 * @brief 返回vaddr在页目录中的索引
 */
static inline uint32_t pde_index (uint32_t vaddr) {
    int index = (vaddr >> 22); // 只取高10位
    return index;
}

/**
 * @brief 获取pde中地址
 */
static inline uint32_t pde_paddr (pde_t * pde) {
    return pde->phy_pt_addr << 12;
}

/**
 * @brief 返回vaddr在页表中的索引
 */
static inline int pte_index (uint32_t vaddr) {
    return (vaddr >> 12) & 0x3FF;   // 取中间10位
}

/**
 * @brief 获取pte中的物理地址
 */
static inline uint32_t pte_paddr (pte_t * pte) {
    return pte->phy_page_addr << 12;
}

/**
 * @brief 获取pte中的权限位
 */
static inline uint32_t get_pte_perm (pte_t * pte) {
    return (pte->v & 0x1FF);                   // 2023年2月19 同学发现有问题，改了下
}


/**
 * @brief 重新加载整个页表
 * @param vaddr 页表的虚拟地址
 */
static inline void mmu_set_page_dir (uint32_t paddr) {
    // 将虚拟地址转换为物理地址
    write_cr3(paddr);
}

#endif // MMU_H
