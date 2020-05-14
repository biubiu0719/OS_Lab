
BITS 16

extern startos
extern cmd           ;汇编调用c函数的方式

global _start              ;让c调用汇编的方式
_start:
    mov	ax, cs                 ; 置其他段寄存器值与CS相同
    mov	ds, ax                 ; 数据段
    mov	es, ax                 ; 数据段
    call  dword startos

Keyboard:
    mov	ax, cs                 ; 置其他段寄存器值与CS相同
    mov	ds, ax                 ; 数据段
    mov	es, ax                 ; 数据段
    mov ah, 0
    int 16h
    cmp al, 0dh      ; 按下回车
    jne Keyboard     ; 无效按键，重新等待用户按键
    call   dword cmd ; 进入命令行界面
    jmp Keyboard     ; 无限循环