#include "platform.h"

	# 定义一个常量 STACK_SIZE 表示每个核的栈空间大小为 1024 字节
	.equ	STACK_SIZE, 1024
	# 定义一个全局标签 _start 作为程序入口。
	.global	_start

	.text
_start:
	# park harts with id != 0
	csrr	t0, mhartid		#  读当前 hart 的 id ， hart 的 id 保存在 mhartid 寄存器中
	mv	tp, t0				#  将 t0 的值存入 tp 寄存器，以备后续使用
	bnez	t0, park		#  如果hart id 不等于 0，则跳转到 park 处执行
					
	# Setup stacks, the stack grows from bottom to top, so we put the
	# stack pointer to the very end of the stack range.
	slli	t0, t0, 10		#  将 hart id 左移10位，即乘以 1024，计算每个核的栈地址
	la	sp, stacks + STACK_SIZE	# 将 sp 寄存器指向当前hart的栈空间的结尾处
					
	add	sp, sp, t0			#  最后将 t0 的值加到 sp 中，得到当前核的栈指针


	j	start_kernel		# 跳转到  start_kernel 函数

park:
	wfi 
	j	park

stacks:
	.skip	STACK_SIZE * MAXNUM_CPU # 为所有的核都分配了栈空间 

	.end				# End of file
