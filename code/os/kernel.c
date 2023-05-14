extern void uart_init(void);
extern void uart_puts(char *s);


void start_kernel(void)
{
	uart_init();
	uart_puts("hello RVOS !");
	while (1) {}; // stop here!
}

