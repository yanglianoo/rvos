#include "os.h"

extern void uart_init(void);
extern void page_init();
extern void sched_init(void);
extern void schedule(void);
extern void os_main(void);
extern void trap_init(void);
extern void plic_init(void);
extern void timer_init(void);

void start_kernel(void)
{
	uart_init();
	uart_puts("hello RVOS !");

	page_init();

	trap_init();

	plic_init();
	
	//timer_init();

	sched_init();

	os_main();
	
	schedule();

	uart_puts("Would not go here!\n");
	while (1) {}; // stop here!
}

