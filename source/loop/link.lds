
/**
 * 用于用户态应用程序（loop）的链接脚本
 * 定义了应用程序在内存中的布局结构，指定了代码段、数据段等的起始地址和排列方式，确保应用程序能被操作系统正确加载到用户态地址空间并执行
 */

ENTRY(_start)
SECTIONS
{
	. = 0x83000000;
	.text : {
		*(*.text)
	}

	.rodata : {
		*(*.rodata)
	}

	.data : {
		*(*.data)
	}

	.bss : {
		__bss_start__ = .;
		*(*.bss)
    	__bss_end__ = . ;
	}
}
