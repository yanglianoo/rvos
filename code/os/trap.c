/**
 * @File Name: trap.c
 * @brief  中断处理逻辑
 * @Author : Timer email:330070781@qq.com
 * @Version : 1.0
 * @Creat Date : 2023-05-28
 * 
 */
#include "os.h"

extern void trap_vector(void);
extern void uart_isr(void);
extern void timer_handler(void);
extern void schedule(void);
extern void do_syscall(struct context *cxt);

void trap_init()
{
	/*
	 * 设置 trap 时调用函数的基地址
	 */
	w_mtvec((reg_t)trap_vector);
}

/**
 * @brief  外部中断函数
 */
void external_interrupt_handler()
{
	int irq = plic_claim();

	if (irq == UART0_IRQ){
      		uart_isr();
	} else if (irq) {
		printf("unexpected interrupt irq = %d\n", irq);
	}
	
	if (irq) {
		plic_complete(irq);
	}
}

// 在 trap_vector 函数中将 mepc 和 m_cause 以及上下文指针 cxt 的值传了出来
reg_t trap_handler(reg_t epc, reg_t cause,struct context *cxt)
{
	reg_t return_pc = epc;
	reg_t cause_code = cause & 0xfff;
	
	if (cause & 0x80000000) 
    {
		/* Asynchronous trap - interrupt */
		printf("interruption\n");
		switch (cause_code) {
		case 3:
			uart_puts("software interruption!\n");

			int id = r_mhartid();
    		*(uint32_t*)CLINT_MSIP(id) = 0;
			schedule();

			break;
		case 7:
			uart_puts("timer interruption!\n");
			timer_handler();
			break;
		case 11:
			uart_puts("external interruption!\n");
			external_interrupt_handler();
			break;
		default:
			uart_puts("unknown async exception!\n");
			break;
		}
	} 
    else 
    {
		/* Synchronous trap - exception */
		printf("Sync exceptions!, code = %d\n", cause_code);
		switch (cause_code) {
		case 8:
			uart_puts("System call from U-mode!\n");
			do_syscall(cxt);
			return_pc += 4;
			break;
		default:
			panic("OOPS! What can I do!");
		}
	}

	return return_pc;
}



void trap_test()
{
	/*
	 * Synchronous exception code = 7
	 * Store/AMO access fault
	 */
	*(int *)0x00000000 = 100;

	/*
	 * Synchronous exception code = 5
	 * Load access fault
	 */
	//int a = *(int *)0x00000000;

	uart_puts("Yeah! I'm return back from trap!\n");
}