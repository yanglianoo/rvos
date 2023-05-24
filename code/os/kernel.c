#include "os.h"

extern void page_init();
extern void sched_init(void);
extern void schedule(void);
void start_kernel(void)
{
	uart_init();
	uart_puts("hello RVOS !");

	page_init();

	sched_init();

	schedule();

	while (1) {}; // stop here!
}

