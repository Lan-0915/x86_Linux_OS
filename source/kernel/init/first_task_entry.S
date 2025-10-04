/**
 * 第一个用户态任务的入口点（first_task_entry）
 * 用于在切换到用户态任务（first_task_main）之前完成数据段寄存器的初始化，确保任务运行在正确的内存环境中
 * 内核态到用户态任务切换的过渡代码
 */
 	.text
 	.global first_task_entry
	.extern first_task_main
first_task_entry:
    // 需要重新加载各数据段
    mov %ss, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    jmp first_task_main
   