#include "os.h"

extern void page_init();
extern void sched_init(void);
extern void schedule(void);
extern void os_main(void);
void start_kernel(void)
{
	uart_init();
	uart_puts("hello RVOS !");

	page_init();

	sched_init();

	os_main();
	
	schedule();

	while (1) {}; // stop here!
}

