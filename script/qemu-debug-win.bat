REM 适用于 windows
REM Windows 系统下启动 QEMU 模拟器运行自制 x86 架构操作系统的命令，核心作用是通过 QEMU 加载并调试包含操作系统组件的磁盘映像文件，同时开启调试功能和详细日志输出
start qemu-system-i386  -m 128M -s -S -serial stdio -drive file=disk1.vhd,index=0,media=disk,format=raw -drive file=disk2.vhd,index=1,media=disk,format=raw -d pcall,page,mmu,cpu_reset,guest_errors,page,trace:ps2_keyboard_set_translation
