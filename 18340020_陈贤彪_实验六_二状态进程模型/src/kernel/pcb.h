#include <stdint.h>
uint16_t current_process=0;
#define processnum 10
struct my_Register{
    uint16_t ax;     // 0
	uint16_t cx;     // 2
	uint16_t dx;     // 4
	uint16_t bx;     // 6
	uint16_t sp;     // 8
	uint16_t bp;     // 10
	uint16_t si;     // 12
	uint16_t di;     // 14
	uint16_t ds;     // 16
	uint16_t es;     // 18
	uint16_t fs;     // 20
	uint16_t gs;     // 22
	uint16_t ss;     // 24
	uint16_t ip;     // 26
	uint16_t cs;     // 28
	uint16_t flags;  // 30
};
typedef struct PCB{
	struct my_Register reg;
	uint8_t id;
	uint8_t zhuangtai;
}PCB;
PCB pcb_table[processnum];
struct my_Register r1;
extern uint16_t t_flag;
void Register_init()
{
    for(int i=0;i<processnum;i++)
	{
		pcb_table[i].id=0;
		pcb_table[i].zhuangtai=0;

		pcb_table[i].reg.ax=0;
		pcb_table[i].reg.cx=0;
		pcb_table[i].reg.dx=0;
		pcb_table[i].reg.bx=0;
		pcb_table[i].reg.sp=0xFE00;
		pcb_table[i].reg.si=0;
		pcb_table[i].reg.di=0;
		pcb_table[i].reg.ds=0;
		pcb_table[i].reg.es=0;
		pcb_table[i].reg.fs=0;
		pcb_table[i].reg.gs=0xB800;
		pcb_table[i].reg.ss=0;
		pcb_table[i].reg.ip=0;
		pcb_table[i].reg.cs=0;
		pcb_table[i].reg.flags=512;
	}
    r1.ax=0;
    r1.cx=0;
    r1.dx=0;
    r1.bx=0;
    r1.sp=0xFE00;
    r1.bp=0;
    r1.si=0;
    r1.di=0;
    r1.ds=0;
    r1.es=0;
    r1.gs=0xB800;
    r1.ss=0;
    r1.ip=0;
    r1.cs=0;
    r1.flags=512;
}
struct my_Register* getr1()
{
    return &r1;
}
PCB* getcurrentpcb()
{
    return &pcb_table[current_process];
}
PCB* getfirstpcb()
{
	return &pcb_table[0];
}
void reset()
{
	for(int i=1;i<processnum;i++)
	{
		pcb_table[i].id=i;
		pcb_table[i].zhuangtai=0;

		pcb_table[i].reg.ax=0;
		pcb_table[i].reg.cx=0;
		pcb_table[i].reg.dx=0;
		pcb_table[i].reg.bx=0;
		pcb_table[i].reg.sp=0xFE00;
		pcb_table[i].reg.si=0;
		pcb_table[i].reg.di=0;
		pcb_table[i].reg.ds=0;
		pcb_table[i].reg.es=0;
		pcb_table[i].reg.fs=0;
		pcb_table[i].reg.gs=0xB800;
		pcb_table[i].reg.ss=0;
		pcb_table[i].reg.ip=0;
		pcb_table[i].reg.cs=0;
		pcb_table[i].reg.flags=512;
	}
	current_process=0;
	t_flag=0;
}
void schedule()
{
	pcb_table[current_process].zhuangtai=1;
	current_process++;
	if(current_process>=processnum)current_process=1;
	while(pcb_table[current_process].zhuangtai!=1)
	{	
		current_process++;
		if(current_process>=processnum)current_process=1;	
	}
	pcb_table[current_process].zhuangtai=2;
}
