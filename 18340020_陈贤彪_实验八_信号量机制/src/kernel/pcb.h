#include <stdint.h>
enum PCB_ZHUANGTAI {NEW, READY, RUNNING, BLOCKED, EXIT};
uint16_t current_process=0;
#define processnum 10
#define NRsem 100
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

//extern uint16_t current_process_id;  // 当前进程ID，定义在multiprocess.asm中
extern uint16_t slength;
extern uint16_t fseg, tseg;
extern void stackcopy();
void Register_init()
{
    for(int i=0;i<processnum;i++)
	{
		pcb_table[i].id=i;
		pcb_table[i].zhuangtai=NEW;

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
		pcb_table[i].zhuangtai=NEW;

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
	pcb_table[current_process].zhuangtai=READY;
	current_process++;
	if(current_process>=processnum)current_process=READY;
	while(pcb_table[current_process].zhuangtai!=READY)
	{	
		current_process++;
		if(current_process>=processnum)current_process=READY;	
	}
	pcb_table[current_process].zhuangtai=RUNNING;
}
void schedulepcb()
{
	current_process++;
	if(current_process>=processnum)current_process=READY;
	while(pcb_table[current_process].zhuangtai!=READY)
	{	
		current_process++;
		if(current_process>=processnum)current_process=READY;	
	}
	pcb_table[current_process].zhuangtai=RUNNING;
}
void initsunpcb(uint16_t sunid){
	pcb_table[sunid].id=sunid;
	pcb_table[sunid].zhuangtai=READY;
	pcb_table[sunid].reg.ax=0;
	pcb_table[sunid].reg.cx=getcurrentpcb()->reg.cx;
	pcb_table[sunid].reg.dx=getcurrentpcb()->reg.dx;
	pcb_table[sunid].reg.bx=getcurrentpcb()->reg.bx;
	pcb_table[sunid].reg.sp=getcurrentpcb()->reg.sp;
	pcb_table[sunid].reg.bp=getcurrentpcb()->reg.bp;
	pcb_table[sunid].reg.si=getcurrentpcb()->reg.si;
	pcb_table[sunid].reg.di=getcurrentpcb()->reg.di;
	pcb_table[sunid].reg.ds=getcurrentpcb()->reg.ds;
	pcb_table[sunid].reg.es=getcurrentpcb()->reg.es;
	pcb_table[sunid].reg.fs=getcurrentpcb()->reg.fs;
	pcb_table[sunid].reg.gs=getcurrentpcb()->reg.gs;
	pcb_table[sunid].reg.ss=sunid*0x1000;
	pcb_table[sunid].reg.ip=getcurrentpcb()->reg.ip;
	pcb_table[sunid].reg.cs=getcurrentpcb()->reg.cs;
	pcb_table[sunid].reg.flags=getcurrentpcb()->reg.flags;

	slength=0xFE00-pcb_table[sunid].reg.sp;
	fseg=getcurrentpcb()->reg.ss;
	tseg=pcb_table[sunid].reg.ss;
}
void do_fork()
{
	uint16_t sid = 1;  // 子进程ID
	for(sid=1;sid<processnum;sid++)
	{
		if(pcb_table[sid].zhuangtai==NEW)break;
	}
	if(sid>=processnum)
	{
		getcurrentpcb()->reg.ax=-1;
	}
	else
	{
		getcurrentpcb()->reg.ax=sid;
		initsunpcb(sid);
		stackcopy();
		pcb_table[sid].reg.ax=0;
		pcb_table[sid].id=current_process;
	}
}
void waitfor()
{
	getcurrentpcb()->zhuangtai=BLOCKED;
	schedulepcb();
}
void wakeup(uint16_t id);
void do_exit()
{
	wakeup(getcurrentpcb()->id);
	getcurrentpcb()->zhuangtai=EXIT;
	schedulepcb();

}
void wakeup(uint16_t id)
{
	pcb_table[id].zhuangtai=READY;
}
typedef struct  semaphone  {
    int count;
   int blocked[20];
    int used;
	int que;
}semaphone;
semaphone semlist[NRsem];
int do_GetSema(int value) {
    int i=0;
    while(semlist[i++].used);
    if (i< NRsem) {
      semlist[i].used=1;
      semlist[i].count=value; 
	  semlist[i].que=0;
      return(i);
    }
   else
     return(-1);
}
void do_FreeSema(int s) {
    semlist[s].used=0;
}
void Blocked(int s)
{
	semlist[s].que++;
	pcb_table[current_process].zhuangtai=BLOCKED;
	semlist[s].blocked[semlist[s].que-1]=current_process;
	schedulepcb();
}
void WaitUp(int s)
{
	pcb_table[semlist[s].blocked[0]].zhuangtai=READY;
	for(int i=0;i<semlist[s].que;i++)
	{
		semlist[s].blocked[i]=semlist[s].blocked[i+1];
	}
	semlist[s].que--;

}
void do_P() {
	int s=0;
   semlist[s].count--;
   if (semlist[s].count<0)  Blocked(s);
}
void do_V() {
	int s=0;
   semlist[s].count++;
   if (semlist[s].count<=0)  WaitUp(s);
}


