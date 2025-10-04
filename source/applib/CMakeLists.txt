
# CMake 构建脚本片段，用于定义 C 语言项目的构建规则，主要功能是将源代码编译为静态库，并在构建完成后自动生成用于调试分析的反汇编文件和 ELF 信息文件

project(app LANGUAGES C)    # 定义了一个名为 app 的项目，并指定使用 C 语言进行编译，后续可通过 app 变量引用项目名

file(GLOB C_LIST "*.c" "*.h" "*.S")     # 收集当前目录下所有 .c（C 源文件）、.h（头文件）和 .S（汇编源文件，通常需要预处理）
add_library(${PROJECT_NAME} ${C_LIST})  # 将收集到的文件编译生成名为 app 的静态库，在 Linux/macOS 下会生成 libapp.a 文件

# bin文件生成，写入到image目录下
add_custom_command(TARGET ${PROJECT_NAME}
                   POST_BUILD     # 指定命令在目标构建完成后执行
                   COMMAND ${OBJDUMP_TOOL} -x -d -S -m i386 ${PROJECT_BINARY_DIR}/lib${PROJECT_NAME}.a > ${PROJECT_NAME}_dis.txt    # 使用 objdump 工具生成静态库的反汇编文件
                   COMMAND ${READELF_TOOL} -a ${PROJECT_BINARY_DIR}/lib${PROJECT_NAME}.a > ${PROJECT_NAME}_elf.txt                  # 使用 readelf 工具生成 ELF 格式分析文件
)