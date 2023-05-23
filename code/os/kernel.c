#include "os.h"

extern void page_init();
extern void page_test();
void start_kernel(void)
{
	uart_init();
	uart_puts("hello RVOS !");

	page_init();
	page_test();
	while (1) {}; // stop here!
}

