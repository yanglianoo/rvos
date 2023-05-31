# save all General-Purpose(GP) registers to context
# struct context *base = &ctx_task;
# base->ra = ra;
# ......
.macro reg_save base
	sw ra, 0(\base)
	sw sp, 4(\base)
	sw gp, 8(\base)
	sw tp, 12(\base)
	sw t0, 16(\base)
	sw t1, 20(\base)
	sw t2, 24(\base)
	sw s0, 28(\base)
	sw s1, 32(\base)
	sw a0, 36(\base)
	sw a1, 40(\base)
	sw a2, 44(\base)
	sw a3, 48(\base)
	sw a4, 52(\base)
	sw a5, 56(\base)
	sw a6, 60(\base)
	sw a7, 64(\base)
	sw s2, 68(\base)
	sw s3, 72(\base)
	sw s4, 76(\base)
	sw s5, 80(\base)
	sw s6, 84(\base)
	sw s7, 88(\base)
	sw s8, 92(\base)
	sw s9, 96(\base)
	sw s10, 100(\base)
	sw s11, 104(\base)
	sw t3, 108(\base)
	sw t4, 112(\base)
	sw t5, 116(\base)
	# we don't save t6 here, due to we have used
	# it as base, we have to save t6 in an extra step
	# outside of reg_save
.endm


# restore all General-Purpose(GP) registers from the context
# struct context *base = &ctx_task;
# ra = base->ra;
# ......
.macro reg_restore base
	lw ra, 0(\base)
	lw sp, 4(\base)
	lw gp, 8(\base)
	lw tp, 12(\base)
	lw t0, 16(\base)
	lw t1, 20(\base)
	lw t2, 24(\base)
	lw s0, 28(\base)
	lw s1, 32(\base)
	lw a0, 36(\base)
	lw a1, 40(\base)
	lw a2, 44(\base)
	lw a3, 48(\base)
	lw a4, 52(\base)
	lw a5, 56(\base)
	lw a6, 60(\base)
	lw a7, 64(\base)
	lw s2, 68(\base)
	lw s3, 72(\base)
	lw s4, 76(\base)
	lw s5, 80(\base)
	lw s6, 84(\base)
	lw s7, 88(\base)
	lw s8, 92(\base)
	lw s9, 96(\base)
	lw s10, 100(\base)
	lw s11, 104(\base)
	lw t3, 108(\base)
	lw t4, 112(\base)
	lw t5, 116(\base)
	lw t6, 120(\base)
.endm

.text

# interrupts and exceptions while in machine mode come here.
# mepc 寄存器存储了中断函数的返回地址
# mscratch 寄存器存储的是当前任务上下文的存储地址
# t6 为下一个任务的上下文存储地址
.globl trap_vector
.align 4
trap_vector:
	# save context(registers).
	csrrw	t6, mscratch, t6	# 交换 t6 和 mscratch 的值，此时 mscratch = t6
	reg_save t6					# 以 t6 寄存器中的值为基址，保存当前上下文寄存器的值

	# Save the actual t6 register, which we swapped into mscratch
	mv	t5, t6					# t5 指向当前任务的上下文  
	csrr	t6, mscratch		# 从 mscratch 读取当前任务的上下文地址并赋值给 t6
	sw	t6, 120(t5)				# 以 t5 为基地址将 t6 保存在偏移为 120 的位置，保存t6的值

	# save mepc to context of current task
	csrr	a0, mepc			# 将 mepc 寄存器的值读入 a0 寄存器
	sw	a0, 124(t5)				# 以 t5 为基地址将 a0 保存在偏移为 124 的位置，保存 mepc 的值

	# 将 mscratch 重新指向当前任务上下文
	csrw	mscratch, t5

	# 调用中断处理函数
	csrr	a0, mepc            # 将 mepc 寄存器的值读入 a0 寄存器
	csrr	a1, mcause			# 将 mcause 寄存器的值读入 a1 寄存器
	csrr	a2, mscratch		# 将 mscratch 寄存器的值读入 a2 寄存器
	call	trap_handler		# 调用名为 trap_handler 的 C 中断/异常处理程序

	# trap_handler will return the return address via a0.
	csrw	mepc, a0			# 将 a0 中存储的返回地址存储到 mepc 寄存器

	# restore context(registers).
	csrr	t6, mscratch        # 恢复当前任务的上下文
	reg_restore t6

	# return to whatever we were doing before trap.
	mret

# void switch_to(struct context *next);
# a0: pointer to the context of the next task
# 各个任务的上下文信息都保存在各自的栈中，存储地址通过参数传入，然后赋值给 mscratch
.globl switch_to
.align 4
switch_to:
	# 切换 mscratch 寄存器的指针，使其指向下一个任务的上下文
	csrw	mscratch, a0
	# set mepc to the pc of the next task
	lw	a1, 124(a0)
	csrw	mepc, a1

	# 恢复所有通用目的寄存器（GP registers）的值
	# 使用 t6 寄存器指向下一个任务的上下文
	mv	t6, a0               
	reg_restore t6

	# Do actual context switching.
	# Notice this will enable global interrupt
	mret
.end