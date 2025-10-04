
REM Windows 批处理脚本（.bat），主要用于为自制操作系统（或底层程序）准备磁盘映像文件（适用于 Windows）, 与 Linux/macOS 下的 Shell 脚本逻辑一致，但适配了 Windows 平台的工具
REM 核心功能是将操作系统的关键组件（引导程序、加载器、内核、应用程序等）写入指定的磁盘映像中，使其能被模拟器（如 QEMU）或真实硬件加载运行
REM .bat 文件是纯文本文件，其中包含了一系列按顺序执行的命令。这些命令与直接在 Windows 命令提示符窗口（黑窗口）中输入的命令完全相同


set DISK1_NAME=disk1.vhd


dd if=boot.bin of=%DISK1_NAME% bs=512 conv=notrunc count=1


dd if=loader.bin of=%DISK1_NAME% bs=512 conv=notrunc seek=1

dd if=kernel.elf of=%DISK1_NAME% bs=512 conv=notrunc seek=100

@REM dd if=init.elf of=%DISK1_NAME% bs=512 conv=notrunc seek=5000
@dd if=shell.elf of=%DISK1_NAME% bs=512 conv=notrunc seek=5000

set DISK2_NAME=disk2.vhd
set TARGET_PATH=k
echo select vdisk file="%cd%\%DISK2_NAME%" >a.txt
echo attach vdisk >>a.txt
echo select partition 1 >> a.txt
echo assign letter=%TARGET_PATH% >> a.txt
diskpart /s a.txt
del a.txt


copy /Y *.elf %TARGET_PATH%:\

echo select vdisk file="%cd%\%DISK2_NAME%" >a.txt
echo detach vdisk >>a.txt
diskpart /s a.txt
del a.txt
