#ifndef __OS_H__
#define __OS_H__
#include <stddef.h>
#include <stdarg.h>

#include "types.h"
#include "platform.h"

/* uart */
extern int uart_putc(char ch);
extern void uart_puts(char *s);

/* printf */
// extern int  printf(const char* s, ...);
// extern void panic(char *s);

/* memeoryr */
extern void *page_alloc(int pages);
extern void page_free(void *p);
#endif