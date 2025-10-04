# 适用于 Linux
# Linux 系统下启动 QEMU 模拟器运行自制 x86 架构操作系统的命令，核心作用是通过 QEMU 加载并调试包含操作系统组件的磁盘映像文件，同时开启调试功能和详细日志输出
qemu-system-i386 -daemonize -m 128M -s -S -drive file=disk1.img,index=0,media=disk,format=raw -drive file=disk2.img,index=1,media=disk,format=raw -d pcall,page,mmu,cpu_reset,guest_errors,page,trace:ps2_keyboard_set_translation



# 解释：

# qemu-system-i386：指定启动的 QEMU 模拟器架构为 i386（32 位 x86 架构），匹配多数自制操作系统的开发目标（x86 是操作系统开发的经典架构）
# -daemonize：以 “守护进程” 模式运行 QEMU（后台运行，不占用当前终端窗口，便于同时进行其他操作，如通过 GDB 连接调试）
# -m 128M：为模拟器分配 128MB 内存（内存大小需根据操作系统需求调整，128M 足够多数轻量级自制内核运行）

# -s： shorthand for -gdb tcp::1234，即开启 GDB 远程调试服务，监听本地 1234 端口。开发者可通过 gdb 命令连接该端口（如 x86_64-elf-gdb -ex "target remote :1234"），实现对操作系统内核的单步调试、断点设置等
# -S：启动 QEMU 后立即暂停 CPU 执行（不自动运行操作系统），需等待 GDB 连接并发送 “继续执行” 命令（continue）才会启动。这是调试操作系统引导阶段的关键选项 —— 确保能从引导程序（boot.bin）的第一行代码开始调试

# 通过 -drive 选项加载两个磁盘映像文件，模拟真实硬件的磁盘设备
    # file=disk1.img：指定加载的磁盘映像文件为 disk1.img（核心启动盘，包含引导程序、加载器、内核）
    # index=0：将该磁盘设置为 “第 0 号磁盘”（通常对应 BIOS 中的 “第一硬盘”，优先作为启动磁盘）
    # media=disk：声明设备类型为 “硬盘”（而非光驱等其他存储设备）
    # format=raw：指定映像格式为 “原始格式”（raw 是无压缩的原始磁盘扇区数据，适配 dd 写入的映像文件）

    # # file=disk2.img：指定加载的磁盘映像文件为 disk2.img（应用程序盘，存储 shell.elf 等用户程序）
    # index=1：将该磁盘设置为 “第 1 号磁盘”，供内核启动后访问
    # media=disk：声明设备类型为 “硬盘”（而非光驱等其他存储设备）
    # format=raw：指定映像格式为 “原始格式”（raw 是无压缩的原始磁盘扇区数据，适配 dd 写入的映像文件）

# -d pcall,page,mmu,cpu_reset,guest_errors,page,trace:ps2_keyboard_set_translation 开启 QEMU 的详细调试日志输出，记录特定硬件 / 软件事件，用于排查操作系统运行中的底层问题
    # pcall：记录 CPU 指令调用相关信息
    # page：记录内存分页（页表）操作日志（关键，用于调试内存管理模块）
    # mmu：记录内存管理单元（MMU）的工作状态（如地址转换、权限检查）
    # cpu_reset：记录 CPU 复位事件（如系统启动、异常触发的复位）
    # guest_errors：记录客户机（即自制操作系统）触发的错误（如非法指令、内存访问越界）
    # trace:ps2_keyboard_set_translation：专门追踪 PS/2 键盘的 “翻译模式” 配置（用于调试键盘驱动相关问题）