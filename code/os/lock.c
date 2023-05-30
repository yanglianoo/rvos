/**
 * @File Name: lock.c
 * @brief  自旋锁
 * @Author : Timer email:330070781@qq.com
 * @Version : 1.0
 * @Creat Date : 2023-05-30
 * 
 */
#include "os.h"


int spin_lock()
{
	w_mstatus(r_mstatus() & ~MSTATUS_MIE);
	return 0;
}


int spin_unlock()
{
	w_mstatus(r_mstatus() | MSTATUS_MIE);
	return 0;
}