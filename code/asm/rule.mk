include ../../common.mk

.DEFAULT_GOAL := all
all:
	@${CC} ${CFLAGS} ${SRC} -Ttext=0x80000000 -o ${EXEC}.elf
	@${OBJCOPY} -O binary ${EXEC}.elf ${EXEC}.bin

.PHONY : run
run: all
	@echo "Press Ctrl-A and then X to exit QEMU"
	@echo "------------------------------------"
	@echo "No output, please run 'make debug' to see details"
	@${QEMU} ${QFLAGS} -kernel ./${EXEC}.elf


.PHONY : debug
debug: all
	@echo "Press Ctrl-C and then input 'quit' to exit GDB and QEMU"
	@echo "-------------------------------------------------------"
	@${QEMU} ${QFLAGS} -kernel ${EXEC}.elf -s -S &
	@${GDB} ${EXEC}.elf -q -x ${GDBINIT}
#  -x ${GDBINIT} gdb的配置脚本
#  -q 启动时不显示版本信息、配置选项和欢迎消息等信息，直接进入 GDB 命令行界面

# 反汇编输出汇编代码
.PHONY : code
code: all
	@${OBJDUMP} -S ${EXEC}.elf | less


.PHONY : hex
hex: all
	@hexdump -C ${EXEC}.bin

.PHONY : clean
clean:
	rm -rf *.o *.bin *.elf
