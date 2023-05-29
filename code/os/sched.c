#include "os.h"


/* defined in entry.S */
extern void switch_to(struct context *next);

/* 此操作系统最大支持10个进程*/
#define MAX_TASKS 10
/* 每个进程栈的大小为 1024byte = 1K*/
#define STACK_SIZE 1024
uint8_t task_stack[MAX_TASKS][STACK_SIZE];
/* 定义10个进程的寄存器结构体*/
struct context ctx_tasks[MAX_TASKS];

/*
 * _top is used to mark the max available position of ctx_tasks
 * _current is used to point to the context of current task
 */
static int _top = 0;
static int _current = -1;


void user_task0(void);
void sched_init()
{
	w_mscratch(0);
}

void schedule()
{
	if (_top <= 0) 
	{
		panic("Num of task should be greater than zero!");
		return;
	}
	//任务轮转
	_current = (_current + 1) % _top;
	struct context *next = &(ctx_tasks[_current]);
	switch_to(next);

}

/*
 * DESCRIPTION
 * 	Create a task.
 * 	- start_routin: task routine entry
 * RETURN VALUE
 * 	0: success
 * 	-1: if error occured
 */
int task_create(void *(*task)(void))
{
	if(_top < MAX_TASKS)
	{
		ctx_tasks[_top].sp = (reg_t) &task_stack[_top][STACK_SIZE-1];
		ctx_tasks[_top].ra = (reg_t) task;
		_top ++;
		return 0;
	}
	else
	{
		return -1;
	}
}
/*
 * DESCRIPTION
 * 	task_yield()  causes the calling task to relinquish the CPU and a new 
 * 	task gets to run.
 */
void task_yield()
{
	schedule();
}

/*
 * a very rough implementaion, just to consume the cpu
 */
void task_delay(volatile int count)
{
	count *= 50000;
	while (count--);
}

