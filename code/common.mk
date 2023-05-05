# 定义通用编译变量

# 编译相关参数
CROSS_COMPILE = riscv64-unknown-elf-
CFLAGS = -nostdlib -fno-builtin -march=rv32ima -mabi=ilp32 -g -Wall

# "-nostdlib": 告诉编译器不使用标准库（例如 libc），这意味着需要自己实现一些常用函数，如 printf 和 exit。
# "-fno-builtin": 禁止编译器使用内建函数（built-in function），这些函数通常由编译器实现，例如 memcpy 和 memset。
# "-march=rv32ima": 指定编译生成的代码是 RISC-V ISA 中的 RV32IMA 指令集架构，其中 "RV32" 表示 32 位 RISC-V 架构，"I" 表示基本整数指令集，"M" 表示乘法扩展指令集，"A" 表示原子操作扩展指令集。
# "-mabi=ilp32": 指定编译生成的代码使用 ILP32 数据模型，其中 "I" 表示整数类型使用 32 位，"L" 表示长整数类型使用 32 位，"P" 表示指针类型使用 32 位。
# "-g": 生成调试信息，以便使用调试器进行调试。
# "-Wall": 开启所有警告信息，这可以帮助检测代码中的潜在问题。


#qemu模拟器相关参数
QEMU = qemu-system-riscv32
QFLAGS = -nographic -smp 1 -machine virt -bios none


GDB = gdb-multiarch
# riscv64-unknown-elf-gcc 工具链可以同时编译汇编和 C 代码
CC = ${CROSS_COMPILE}gcc
OBJCOPY = ${CROSS_COMPILE}objcopy
OBJDUMP = ${CROSS_COMPILE}objdump