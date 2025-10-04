
# Shell 脚本，主要用于为自制操作系统（或底层程序）准备磁盘映像文件（适用于 Linux）
# 核心功能是将操作系统的关键组件（引导程序、加载器、内核、应用程序等）写入指定的磁盘映像中，使其能被模拟器（如 QEMU）或真实硬件加载运行


if [ -f "disk1.vhd" ]; then
    mv disk1.vhd disk1.img
fi

if [ ! -f "disk1.img" ]; then
    echo "error: no disk1.vhd, download it first!!!"
    exit -1
fi

if [ -f "disk2.vhd" ]; then
    mv disk2.vhd disk2.img
fi

if [ ! -f "disk2.img" ]; then
    echo "error: no disk2.vhd, download it first!!!"
    exit -1
fi

export DISK1_NAME=disk1.img

# 写boot区，定位到磁盘开头，写1个块：512字节
# boot.bin 是操作系统的 “第一阶段引导程序”，必须写入磁盘的第 1 个扇区（0 号扇区），才能被 BIOS/UEFI 识别并加载
dd if=boot.bin of=$DISK1_NAME bs=512 conv=notrunc count=1

# 写loader区，定位到磁盘第2个块，写1个块：512字节
# loader.bin 是 “第二阶段加载器”—— 引导程序（boot.bin）体积有限（仅 512 字节），无法直接加载内核，需通过 loader 进一步读取内核到内存
dd if=loader.bin of=$DISK1_NAME bs=512 conv=notrunc seek=1

# 写kernel区，定位到磁盘第100个块
# kernel.elf 是操作系统内核（编译后的可执行文件），体积较大，需放在磁盘的后续位置；loader 会根据预设的 “第 100 个块” 地址读取内核并启动
dd if=kernel.elf of=$DISK1_NAME bs=512 conv=notrunc seek=100

# 写应用程序init，临时使用
# dd if=init.elf of=$DISK1_NAME bs=512 conv=notrunc seek=5000
# dd if=shell.elf of=$DISK1_NAME bs=512 conv=notrunc seek=5000

# 写应用程序，使用系统的挂载命令
export DISK2_NAME=disk2.img     # 定义应用磁盘变量
export TARGET_PATH=mp           # 定义挂载点目录（临时目录，用于访问磁盘内容）
rm -rf $TARGET_PATH             # 删除旧的挂载点，下一行重新创建空目录
mkdir $TARGET_PATH
sudo mount -o offset=$[128*512],rw $DISK2_NAME $TARGET_PATH     # 挂载 disk2.img 到 mp 目录（offset 表示跳过前 128*512=65536 字节）
                                                                # 将虚拟磁盘映像（disk2.img）当作真实磁盘挂载到系统，这样就能用普通文件操作（cp）复制应用程序
# sudo cp -v init.elf $TARGET_PATH/init
# sudo cp -v shell.elf $TARGET_PATH
# sudo cp -v loop.elf $TARGET_PATH/loop
# sudo cp -v snake.elf $TARGET_PATH/snake
sudo cp -v *.elf $TARGET_PATH       # 将当前目录下所有 .elf 格式的应用程序复制到挂载点（即 disk2.img 内）

sudo umount $TARGET_PATH            # 卸载磁盘映像（必须卸载，否则修改不会写入磁盘文件）
