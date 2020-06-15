#include <stdint.h>
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
struct my_Register r1;

void Register_init()
{
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
