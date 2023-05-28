/**
 * @File Name: trap.c
 * @brief  
 * @Author : Timer email:330070781@qq.com
 * @Version : 1.0
 * @Creat Date : 2023-05-28
 * 
 */
#include "riscv.h"

extern void trap_vector(void);

void trap_init()
{
	/*
	 * 设置 trap 时调用函数的基地址
	 */
	w_mtvec((reg_t)trap_vector);
}

reg_t trap_handler(reg_t epc, reg_t cause)
{
	reg_t return_pc = epc;
	reg_t cause_code = cause & 0xfff;
	
	if (cause & 0x80000000) 
    {
		/* Asynchronous trap - interrupt */
		switch (cause_code) {
		case 3:
			uart_puts("software interruption!\n");
			break;
		case 7:
			uart_puts("timer interruption!\n");
			break;
		case 11:
			uart_puts("external interruption!\n");
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
		panic("OOPS! What can I do!");
		//return_pc += 4;
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