/**
 * @File Name: timer.c
 * @brief  : 定时器，包括硬件定时器和软件定时器
 * @Author : Timer email:330070781@qq.com
 * @Version : 1.0
 * @Creat Date : 2023-05-29
 * 
 */
#include "os.h"

extern void schedule(void);
/* interval ~= 1s */
#define TIMER_INTERVAL CLINT_TIMEBASE_FREQ

static uint32_t _tick = 0;

#define MAX_TIMER 10
static struct timer timer_list[MAX_TIMER];

/* load timer interval(in ticks) for next timer interrupt.*/
void timer_load(int interval)
{
	/* each CPU has a separate source of timer interrupts. */
	int id = r_mhartid();
	
	*(uint64_t*)CLINT_MTIMECMP(id) = *(uint64_t*)CLINT_MTIME + interval;
}


void timer_init()
{
	/* 初始化timer */
	for(int i=0; i<MAX_TIMER; i++)
	{
		timer_list[i].func = NULL;
		timer_list[i].arg = NULL; 
	}
	/*
	 * On reset, mtime is cleared to zero, but the mtimecmp registers 
	 * are not reset. So we have to init the mtimecmp manually.
	 */
	timer_load(TIMER_INTERVAL);

	/* enable machine-mode timer interrupts. */
	w_mie(r_mie() | MIE_MTIE);

	/* enable machine-mode global interrupts. */
	//w_mstatus(r_mstatus() | MSTATUS_MIE);
}

struct timer *timer_create(void (*handler)(void *arg), void *arg, uint32_t timeout)
{
	if (NULL == handler || 0 == timeout) {
		return NULL;
	}
	spin_lock();

	struct timer *t = &(timer_list[0]);
	for (int i = 0; i < MAX_TIMER; i++) {
		if (NULL == t->func) {
			break;
		}
		t++;
	}
	if (NULL != t->func) {
		spin_unlock();
		return NULL;
	}

	t->func = handler;
	t->arg = arg;
	t->timeout_tick = _tick + timeout;

	spin_unlock();

	return t;

}

void timer_delete(struct timer *timer)
{
	spin_lock();
	struct timer *t = &(timer_list[0]);
	for (int i = 0; i < MAX_TIMER; i++) {
		if (t == timer) {
			t->func = NULL;
			t->arg = NULL;
			break;
		}
		t++;
	}

	spin_unlock();
}

static inline void timer_check()
{
	struct timer *t = &(timer_list[0]);
	for (int i = 0; i < MAX_TIMER; i++) {
		if (NULL != t->func) {
			if (_tick >= t->timeout_tick) {
				t->func(t->arg);

				/* once time, just delete it after timeout */
				t->func = NULL;
				t->arg = NULL;

				break;
			}
		}
		t++;
	}
}

void timer_handler() 
{
	_tick++;
	printf("tick: %d\n", _tick);

	timer_check();

	timer_load(TIMER_INTERVAL);

	schedule();
}