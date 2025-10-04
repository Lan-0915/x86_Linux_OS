/**
 * 内核初始化以及测试代码
 */
#include "applib/lib_syscall.h"
#include "dev/tty.h"

int first_task_main (void) {
#if 0       // ... 测试代码 ...  #if 0 表示这段代码不生效
    int count = 3;

    int pid = getpid();
    print_msg("first task id=%d", pid);

    pid = fork();
    if (pid < 0) {
        print_msg("create child proc failed.", 0);
    } else if (pid == 0) {
        print_msg("child: %d", count);

        char * argv[] = {"arg0", "arg1", "arg2", "arg3"};
        execve("/shell.elf", argv, (char **)0);
    } else {
        print_msg("child task id=%d", pid);
        print_msg("parent: %d", count);
    }

    pid = getpid();
    for (;;) {
        print_msg("task id = %d", pid);
        msleep(1000);
    }
#endif

    for (int i = 0; i < TTY_NR; i++) {
        int pid = fork();   // 创建子进程
        if (pid < 0) {
            print_msg("create shell proc failed", 0);
            break;          // 创建失败则退出循环
        } else if (pid == 0) {
            // 子进程创建成功
            char tty_num[] = "/dev/tty?";
            tty_num[sizeof(tty_num) - 2] = i + '0';     // 替换"?"为终端编号（如0→tty0，1→tty1）
            char * argv[] = {tty_num, (char *)0};       // 命令行参数：指定shell绑定的TTY设备
            execve("shell.elf", argv, (char **)0);      // 加载并执行shell程序（替换当前进程镜像）
            
            // 如果execve失败（如shell.elf不存在），则进入休眠
            print_msg("create shell proc failed", 0);
            while (1) {
                msleep(10000);  // 10秒休眠，避免占用CPU
            }
        }
    }

    while (1) {
        // 不断收集孤儿进程
        int status;
        wait(&status);
        //msleep(10000);
    }

    return 0;
} 