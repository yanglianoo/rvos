# Calling Convention
# Demo to create a leaf routine
#
# void _start()
# {
#     // calling leaf routine
#     square(3);
# }
#
# int square(int num)
# {
#     return num * num;
# }

	.text			# Define beginning of text section
	.global	_start		# Define entry _start

_start:
	la sp, stack_end	# 准备栈指针

	li a0, 3			# 参数 a0 为第一个参数
	call square			# 函数调用

	# the time return here, a0 should stores the result
stop:
	j stop			# Infinite loop to stop execution

# int square(int num)
square:
	# prologue
	addi sp, sp, -8    # 压栈 分配 8 字节空间
	sw s0, 0(sp)  	   # 压入 s0
	sw s1, 4(sp)	   # 压入 s1

	# `mul a0, a0, a0` should be fine,
	# programing as below just to demo we can contine use the stack
	mv s0, a0
	mul s1, s0, s0
	mv a0, s1

	# epilogue
	lw s0, 0(sp)
	lw s1, 4(sp)
	addi sp, sp, 8      #恢复栈

	ret

	# add nop here just for demo in gdb
	nop

	# allocate stack space
stack_start:
	.rept 12
	.word 0
	.endr
stack_end:

	.end			# End of file

