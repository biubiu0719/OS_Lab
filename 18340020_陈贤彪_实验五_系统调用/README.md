# 操作系统-实验五

学号：18340020	姓名：陈贤彪	学院：数据科学与计算机学院

## 1.实验目的

1、学习掌握PC系统的软中断指令

2、掌握操作系统内核对用户提供服务的系统调用程序设计方法

3、掌握C语言的库设计方法

4、掌握用户程序请求系统服务的方法

## 2.实验要求

1、了解PC系统的软中断指令的原理

2、掌握`x86`汇编语言软中断的响应处理编程方法

3、扩展实验四的的内核程序，增加输入输出服务的系统调用。

4、C语言的库设计，实现`putch()`、`getch()`、`printf()`、`scanf()`等基本输入输出库过程。

5、编写实验报告，描述实验工作的过程和必要的细节，如截屏或录屏，以证实实验工作的真实性

## 3.实验内容

(1) 修改实验4的内核代码，先编写save()和restart()两个汇编过程，分别用于中断处理的现场保护和现场恢复，内核定义一个保护现场的数据结构，以后，处理程序的开头都调用save()保存中断现场，处理完后都用restart()恢复中断现场。

(2) 内核增加`int 20h`、`int 21h`和`int 22h`软中断的处理程序，其中，`int 20h`用于用户程序结束是返回内核准备接受命令的状态；`int 21h`用于系统调用，并实现3-5个简单系统调用功能；`int 22h`功能未定，先实现为屏幕某处显示`int 22H`。

(3) 保留无敌风火轮显示，取消触碰键盘显示OUCH!这样功能。

(4) 进行C语言的库设计，实现`putch()`、`getch()`、`gets()`、`puts()`、`printf()`、`scanf()`等基本输入输出库过程，汇编产生`libs.obj`。

(5) 利用自己设计的C库`libs.obj`，编写一个使用这些库函数的C语言用户程序，再编译,在与`libs.obj`一起链接，产生COM程序，增加内核命令执行这个程序。

(6)编写实验报告，描述实验工作的过程和必要的细节，如截屏或录屏，以证实实验工作的真实性

## 4.实验方案

### 1）实验环境

​	a)系统：`Linux Ubuntu18.04`

### 2）实验工具

​	a)`VM VirtualBox`

​		虚拟机软件，用于模拟虚拟不同的操作系统，也可以创建多个虚拟软盘

​	b)`NASM-2.13.02`

​		汇编语言编译器，可以将写好的`.asm`文件编译成二进制文件.bin

​	c)`gcc (Ubuntu 5.5.0-12ubuntu1) 5.5.0 20171010`

​		c语言编译器

​	d)Visual Studio Code

​		代码编辑器,用于编辑`asm`代码

​	e)`GNU bash version 4.4.20(1)-release (x86_64-pc-linux-gnu)`

​		系统跟计算机硬件交互时使用的中间介质,用于简便对文件进行转换

​	f)`GNU ld (GNU Binutils for Ubuntu) 2.30`

​		链接器，将汇编与c生成的.o文件链接在一起

​	f)`github`

​		开源代码托管平台,用于存储管理编写的代码

​	g)`bochs 2.6.11`

​		软盘调试工具

### 3）实验原理	


#### （1）总体磁盘架构

| 柱面号 | 磁头号 | 扇区偏移 | 占用扇区数 | 功能             |
| ------ | ------ | -------- | ---------- | ---------------- |
| 0      | 0      | 1        | 1          | 引导扇区程序     |
| 0      | 0~1    | 2        | 35         | 操作系统内核     |
| 1      | 0      | 1        | 2          | `userpro1`       |
| 1      | 0      | 3        | 2          | `userpro2`       |
| 1      | 0      | 5        | 2          | `userpro3`       |
| 1      | 0      | 7        | 2          | `userpro4`       |
| 1      | 0      | 9        | 2          | 用户程序表`list` |
| 1      | 0      | 11       | 24         | C语言用户程序    |
| 1      | 1      | 17       | 2          | 系统调用测试程序 |

相比于之前的代码量，内核代码越来越多，因此我直接将整个柱面的扇区分配给了内核

`userpro1`对应左上角滚动字符，`userpro2`对应又上角滚动字符，`userpro3`对应左下角滚动字符，`userpro4`对应右下角滚动字符.

c语言用户程序，由于编写了库，因此占用比较多的扇区数目

系统调用的测试程序放在最后面

在内核中，我创建了一个结构体存储用户程序的信息

#### （2）MY操作系统内核的设计

内核程序结构：

| 程序名         | 代码形式 | 作用                                                      |
| -------------- | -------- | --------------------------------------------------------- |
| `kernel.asm`   | `ASM`    | 内核的入口，调用c中的函数，*新增运行风火轮代码*           |
| `kernel_a.asm` | `ASM`    | 包含一些显示打印，IO借口，扇区加载的函数,*运行`ouch`代码* |
| `stdio.h`      | C        | 包含一些对字符串处理的函数                                |
| `kernel_c.asm` | C        | 内核c代码，内核命令的主要部分                             |
| `ouch.asm`     | `ASM`    | 封装了关于`ouch`键盘中断的代码                            |
| `register.h`   | C        | 新增头文件，封装了一个包含所有寄存器的结构体和函数        |
| `system_a.asm` | `ASM`    | 包含关于系统调用（汇编）的函数                            |
| `system_c.c`   | C        | 包含关于系统调用（c语言）的函数                           |

以下是我已经实现的指令功能（新增了run 5 6指令）

| 指令名   | 功能                                                         |
| -------- | ------------------------------------------------------------ |
| clear    | 清楚屏幕                                                     |
| ls       | 调用`list`程序显示用户程序的信息，需要 按`esc`退出           |
| help     | 显示帮助的信息                                               |
| run      | 可以按照自定义顺序运行1234程序，（新增）run 5为系统调用的测试程序，run 6为c程序测试程序 |
| time     | 显示当前系统时间                                             |
| shutdown | 关机                                                         |

#### （3）（新增）save()和restart()的编写

为保护中断前的寄存器，我首先在内核中构建了一个包含所有寄存器的结构体`r1`在`register.h`

```c
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
struct my_Register* getr1()//取得结构体首地址的函数
{
    return &r1;
}
```

构建一个结构体很简单，但是怎样才能保护到所有的寄存器呢。我使用的方法就是使用栈间接保存。

在进入中断函数的一开始，首先调用我定义的一个宏，将所有寄存器押进栈当中，这样可以防止寄存器的改变

```asm
%macro  PUSHALL 0
    push ss
    push gs
    push fs
    push es
    push ds
    push di
    push si
    push bp
    push sp
    push bx
    push dx
    push cx
    push ax
%endmacro
```

随后就可以调用`save（）`来将栈中的寄存器转移进结构体当中。注意：在进入时钟中断后，首先栈中会增加 `psw`、cs、`ip `共 3 个字。因此我之前只压栈了13个寄存器，但栈中已经有了16个值，可以看下面代码中的注释

```assembly
extern getr1
save:
    pusha
    mov bp, sp
    add bp, 16+2                   ; 参数首地址

    call dword getr1			;获取结构体首地址
    mov di, ax
    mov ax, [bp]					
    mov [cs:di], ax
    mov ax, [bp+2]				;最后压栈的ax，对应r1.ax
    mov [cs:di+2], ax
    mov ax, [bp+4]
    mov [cs:di+4], ax
    mov ax, [bp+6]
    mov [cs:di+6], ax
    mov ax, [bp+8]
    mov [cs:di+8], ax
    mov ax, [bp+10]
    mov [cs:di+10], ax
    mov ax, [bp+12]
    mov [cs:di+12], ax
    mov ax, [bp+14]
    mov [cs:di+14], ax
    mov ax, [bp+16]
    mov [cs:di+16], ax
    mov ax, [bp+18]
    mov [cs:di+18], ax
    mov ax, [bp+20]
    mov [cs:di+20], ax
    mov ax, [bp+22]
    mov [cs:di+22], ax
    mov ax, [bp+24]
    mov [cs:di+24], ax
    mov ax, [bp+26]					;ip在栈中的位置
    mov [cs:di+26], ax				
    mov ax, [bp+28]						;cs在栈中的位置
    mov [cs:di+28], ax
    mov ax, [bp+30]					;psw在栈中的位置
    mov [cs:di+30], ax

    popa
    ret
```

通过压栈，并从栈中转移进结构体，能够完整地保存寄存器

`restart（）`的实现。之后问题就是如何将结构体中的值在中断程序的最后放回原来的寄存器当中，我编写了一个宏来表示RESTART。

注意1：因为在汇编中总需要一个寄存器来进行操作，因此我选择`si`来进行，因此`si`的值的恢复需要在最后恢复

注意2：关于`sp`值的恢复，我们需要恢复的`sp`值是在进入中断前用户的`sp`值，但由于我在压栈`sp`之前栈中会增加 `psw、cs、ip` 共 3 个字，然后又压入了 `ss、gs、fs、es、ds、di、si、bp` 共 8 个字，加起来是11个字，因此最后的`sp`需要+22个字节，才能最终恢复。

在恢复完寄存器后，我再一次将`psw、cs、ip` 压栈，因为在中断恢复需要这三个寄存器来回去。

```assembly
%macro  RESTART 0              ; 宏：从PCB中恢复寄存器的值
    call dword getr1
    mov si, ax
    mov ax, [cs:si+0]
    mov cx, [cs:si+2]
    mov dx, [cs:si+4]
    mov bx, [cs:si+6]
    mov sp, [cs:si+8]
    mov bp, [cs:si+10]
    mov di, [cs:si+14]
    mov ds, [cs:si+16]
    mov es, [cs:si+18]
    mov fs, [cs:si+20]
    mov gs, [cs:si+22]
    mov ss, [cs:si+24]
    add sp, 11*2                   ; 恢复正确的sp
    push word[cs:si+30]            ; 新进程flags
    push word[cs:si+28]            ; 新进程cs
    push word[cs:si+26]            ; 新进程ip
    push word[cs:si+12]
    pop si                         ; 恢复si
%endmacro
```



#### （4）（新增）系统调用的表

`INT 21H`：

| 功能号 | 输入参数                                | 输出参数 | 作用                                                        |
| ------ | --------------------------------------- | -------- | ----------------------------------------------------------- |
| 0      | AH=0，es=串段址,`dx`=串首偏移           | 无       | 将`es:dx`位置的一个字符串中的小写变为大写                   |
| 1      | AH=1，es=串段址，`dx`=串首偏移          | 无       | 将`es:dx`位置的一个字符串中的大写变为小写                   |
| 2      | AH=2，es=串段址，`dx`=串首偏移          | ax=整数  | 将`es:dx`位置的一个数字字符串转变对整数                     |
| 3      | AH=3，bx=整数，es=串段址，`dx`=串首偏移 | 无       | 将bx的数值转变对应的`es:dx`位置的一个数字字符串             |
| 4      | AH=4，ch:行号cl:列号,`dx`=串首偏移      | 无       | 将`es:dx`位置的一个字符串显示在屏幕指定位置(ch:行号cl:列号) |

`INT 22H`

| 功能号 | 输入参数 | 输出参数 | 作用                  |
| ------ | -------- | -------- | --------------------- |
| 0      | AH=0     | 无       | 屏幕某处显示`int 22H` |

#### （5）系统调用的入口程序

由于系统调用的本质就是软中断的程序调用。因此我需要编写一个向量`21h`的入口程序，并且能够识别ah来进入不同的功能号不同的子程序。我实现的方式便是建一个向量表，根据ah的值的跳转进调用表上对应的函数。

注意：有一点便是ax的恢复问题，我会在踩坑过程中详细讲述

`system_call`的实现在`kernel/kernel_a.asm`

```assembly
system_call:  
    PUSHALL
    call save

    push ds
    push si
    mov si,cs
    mov ds,si
    mov si,ax
    shr si,8
    add si,si
    call [system_table+si]
    
    mov cx,ax
    push cx
    call dword getr1
    pop cx
    mov si, ax
    mov [cs:si+0],cx

    pop si
    pop ds

    RESTART

    iret			;中断返回
system_table:
    dw toupper_a,tolower_a,atoi_a,itoa_a
    dw printInpos_a
```

然后将该程序写进`21h`向量中

```assembly
    WRITE_INT_VECTOR 21h, system_call
```

由于写向量的操作也会经常使用，因此我使用宏来进行

```assembly
%macro WRITE_INT_VECTOR 2   
    push ax
    push es
    mov ax, 0
    mov es, ax              ; ES = 0
    mov word[es:%1*4], %2   ; 设置中断向量的偏移地址
    mov ax,cs
    mov word[es:%1*4+2], ax ; 设置中断向量的段地址=CS
    pop es
    pop ax
%endmacro
```

#### （6） `INT21H	ah=00h `的系统调用

​	功能是一个字符串中的小写变为小写，实现方式为汇编+c，汇编在`./lib/system_a.asm`中，c语言在`./lib/system_c.c`

```assembly
global toupper_a
extern toupper_c
toupper_a:
    push es           ; 传递参数
    push dx           ; 传递参数
    call dword toupper_c
    pop dx            ; 丢弃参数
    pop es            ; 丢弃参数
    ret
```

```c
void toupper_c(char* str) {
    int i=0;
    while(str[i]) {
        if (str[i] >= 'a' && str[i] <= 'z')  
        str[i] = str[i]-'a'+'A';
        i++;
    }
}
```

#### （7）`INT21H	ah=01h `的系统调用

​	功能是一个字符串中的大写变为小写，实现方式为汇编+c，汇编在`./lib/system_a.asm`中，c语言在`./lib/system_c.c`

```assembly
global tolower_a
extern tolower_c
tolower_a:
    push es           ; 传递参数
    push dx           ; 传递参数
    call dword tolower_c
    pop dx            ; 丢弃参数
    pop es            ; 丢弃参数
    ret
```

```c
void tolower_c(char* str) {
    int i=0;
    while(str[i]) {
        if (str[i] >= 'A' && str[i] <= 'Z')  
        str[i] = str[i]-'A'+'a';
        i++;
    }
}
```

#### （8）`INT21H	ah=02h `的系统调用

​	功能是将字符串转整数，实现方式为汇编+c，汇编在`./lib/system_a.asm`中，c语言在`./lib/system_c.c`

```assembly
global atoi_a
extern atoi_c
atoi_a:
    push es           ; 传递参数;
    push dx           ; 传递参数
    call dword atoi_c
    pop dx            ; 丢弃参数
    pop es            ; 丢弃参数
    ret
```

```c
//字符串转数字
extern int strlen(char *);
int atoi_c(char *str) {
    int res = 0; // Initialize result 
 int len=strlen(str);
    for (int i = 0; i<len; ++i) {
        res = res*10 + str[i] - '0'; 
    }
    // return result. 
    return res; 
}
```

#### （9）`INT21H	ah=03h `的系统调用

​	功能是将整数转字符串，实现方式为汇编+c，汇编在`./lib/system_a.asm`中，c语言在`./lib/system_c.c`

```assembly
global itoa_a
extern itoa_c
itoa_a:
    push es           ; 传递参数buf
    push dx           ; 传递参数buf
    mov ax, 0
    push ax           ; 传递参数base
    mov ax, 10        ; 10进制
    push ax           ; 传递参数base
    mov ax, 0
    push ax           ; 传递参数val
    push bx           ; 传递参数val
    call dword itoa_c
    pop bx            ; 丢弃参数
    pop ax            ; 丢弃参数
    pop ax            ; 丢弃参数
    pop ax            ; 丢弃参数
    pop dx            ; 丢弃参数
    pop es            ; 丢弃参数
    ret
```

```c
char* itoa_c(int num, int base, char* str)
{
	int i = 0;
	int isNegative = 0;
	if (num == 0) {
		str[i] = '0';
		str[i + 1] = '\0';
		return str;
	}
	if (num < 0 && base == 10) {
		isNegative =1;
		num = -num;
	}
	while (num != 0) {
		int rem = num % base;
		str[i++] = (rem > 9) ? (rem - 10) + 'A' : rem + '0';
		num = num / base;
	}
	if (isNegative==1) {
		str[i++] = '-';
	}
	str[i] = '\0';
	reverse(str, i);
	return str;
}
```

#### （10）`INT21H	ah=04h `的系统调用

​	功能是在指定位置打印字符串，由于`bios`中已经有该功能，因此只需要使用，便可

```assembly
extern strlen
printInpos_a:
    pusha
    mov bp, dx        ; es:bp=串地址
    push es           ; 传递参数
    push bp           ; 传递参数
    call dword strlen ; 返回值ax=串长
    pop bp            ; 丢弃参数
    pop es            ; 丢弃参数
    mov bl, 07h       ; 颜色
    mov dh, ch        ; 行号
    mov dl, cl        ; 列号
    mov cx, ax        ; 串长
    mov bh, 0         ; 页码
    mov al, 0         ; 光标不动
    mov ah, 13h       ; BIOS功能号
    int 10h
    popa
    ret
```

#### （11）`INT22H	ah=00h `的系统调用

功能是在屏幕上显示`int 22H`。`int22`属于另外一个向量上，而且和`int21`的模式基本相似，因此只需要重复一样的工作并写入向量表上便可。

```assembly
global showint22
showint22:
    pusha
    PRINT strint22,strint22_len,13,20
    popa
    ret
data1:
    strint22 db 'int 22H'
    strint22_len equ ($-strint22)
```

#### （12）系统调用测试程序

在写完所以的系统调用后，需要写一个测试程序来进行测试调用情况。由于该部分程序的编写相对比较简单，因此我就仅举一个测试例子。该测试程序可通过`run 5`来调用。

测试功能号`00h`：小写变大写的系统调用

```assembly
test_upper:
    mov ax,cs
    mov es,ax
    mov dx,string			;将需要操作的字符串首地址放进dx
    mov ah,00h				;功能号
    int 21h						;系统调用
    PRINT string,string_len,3,15
    
    mov ah,0
    int 16h
    cmp al,27			;若按esc便退出测试程序
    je quit
    
    string db 'aaaBBBcccDDDeee'
    string_len equ ($-string)
```

其他测试的方式都相似，具体的显示效果请看实验结果部分

#### （13）C语言的基本输入输出库的设计

实现`putch()`、`getch()`、`gets()`、`puts()`、`printf()`、`scanf()`等基本输入输出库过程

**注意**：由于在实验三的时候，我在**实验三c内核**的设计的时候已经封装实现过不少的基本库，但是函数名称不同，因此我直接重新调用原有函数名来定义便可。

该库的所有实现都在`./usrpro/c_test/stdio.h`中

- `putchar()`的实现

该函数的实现需要通过汇编的u`int 10h`中断来实现，并且在内核中我已经实现过，因此我直接调用。

汇编中：

```assembly
global putchar_color
putchar_color:                        ; 函数：在光标处打印一个彩色字符
    pusha
    push ds
    push es
    mov bx, 0                   ; 页号=0
    mov ah, 03h                 ; 功能号：获取光标位置
    int 10h                     ; dh=行，dl=列
    mov ax, cs
    mov ds, ax                  ; ds = cs
    mov es, ax                  ; es = cs
    mov bp, sp
    add bp, 20+4                ; 参数地址，es:bp指向要显示的字符
    mov cx, 1                   ; 显示1个字符
    mov ax, 1301h               ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
    mov bh, 0                   ; 页号
    mov bl, [bp+4]              ; 颜色属性
    int 10h                     ; 显示字符串（1个字符）
    pop es
    pop ds
    popa
    retf
```

c中实现

```c
extern void putchar_color(char c,int color);//在光标处打印一个字符
void putchar(char c) {
    putchar_color(c, 0x07);
}
```

- `getch()`的实现

`getch()`的实现同样需要汇编的中断来实现

```assembly
global getch
getch:                     ; 读取一个字符
    mov ah, 0              ; 功能号
    int 16h                ; 读取字符，al=读到的字符
    retf
```

- `gets()`的实现

`gets()`的实现，我在实验三中曾经写过一个`void readcmd(char* *buffer*,int *maxlen*)`的函数，可以获取一整行的指定输入字数的输入，具体实现如下：

```c
void readcmd(char* buffer,int maxlen)
{
    int i=0;
    while(1)
    {
        char tempc=getch();
        if(!(tempc==0xD || tempc=='\b' || tempc>=32 && tempc<=127))
        {
            continue;
        }
        if(i>0&&i<maxlen-1)
        {
            if(tempc==0x0D)
            {
                break;//回车，停止读取
            }
            else if(tempc=='\b')//删除键
            {
                putchar('\b');
                putchar(' ');
                putchar('\b');
                i--;
            }
            else
            {
                putchar_color(tempc,9);  
                buffer[i] = tempc;
                ++i;
            }         
        }
        else if(i>=maxlen-1)//达到字符最大值，只能退课或回车
        {
                if(tempc == '\b') 
                {  // 按下退格，则删除一个字符
                putchar('\b');
                putchar(' ');
                putchar('\b');
                i--;
                }
            else if(tempc == 0x0D) 
            {
                break;  // 按下回车，停止读取
            }
        }
        else if(i<=0)
        {
            if(tempc == 0x0D) {
                break;  // 按下回车，停止读取
            }
            else if(tempc != '\b') {
                putchar_color(tempc,9);  
                buffer[i] = tempc;
                ++i;
            }
        }
    }
    putchar('\r'); putchar('\n');
    buffer[i] = '\0';  
}
```

因此：`gets()`只需要直接调用便可

```c
void gets(char* buffer)
{
    readcmd( buffer,20);
}
```

- `puts()`的实现

`puts()`的实现也与我之前实验三中`print()`一样，打印一个字符串，具体实现如下：

```c
void print(const char* str) {
    int len=strlen(str);
    for(int i = 0; i < len; i++) {
        putchar(str[i]);
    }
}
```

因此`puts(const char* str)`直接调用便可

```c
void puts(const char* str)
{
    print(str);
}
```

- `my_printf()`的实现

`my_printf()`和`my_scanf()`的实现的核心部分就可变参数的函数的编程方式

可变参数实现原理： C调用约定下可使用`va_list`系列变参宏实现变参函数，用法如下：

```c
#include <stdarg.h>
int VarArgFunc(int dwFixedArg, ...){ //以固定参数的地址为起点依次确定各变参的内存起始地址
    va_list pArgs = NULL;  //定义va_list类型的指针pArgs，用于存储参数地址
    va_start(pArgs, dwFixedArg); //初始化pArgs指针，使其指向第一个可变参数。该宏第二个参数是变参列表的前一个参数，即最后一个固定参数
    int dwVarArg = va_arg(pArgs, int); //该宏返回变参列表中的当前变参值并使pArgs指向列表中的下个变参。该宏第二个参数是要返回的当前变参类型
    //若函数有多个可变参数，则依次调用va_arg宏获取各个变参
    va_end(pArgs);  //将指针pArgs置为无效，结束变参的获取
    /* Code Block using variable arguments */
}
```

因此有了这个可变参数的处理，我就可以开始实现`printf`函数了，实现方式：循环遍历第一个字符串，每当遇到‘%’，则根据后面字符的不同输出不同的字符，具体代码如下：

```c
int my_printf(const char* fmt,...)
{
    va_list arg_ptr;
    char arry[100];
    char *str;
    va_start(arg_ptr,fmt);
    while((*fmt)!='\0')
    {
        if(*fmt=='\n')
        {
            putchar('\n');
            putchar('\r');
        }
        else if(*fmt=='%')
        {
            fmt++;
            switch(*fmt)
            {
                case 'd':
                {
                    itoa_c(va_arg(arg_ptr,int),10,arry);//整数转字符串
                    str=arry;
                    while(*str!='\0')
                    {
                        putchar(*str);
                        str++;
                    }
                }break;
                case 's':
                {
                    str=va_arg(arg_ptr,char*);
                    while(*str!='\0')
                    {
                        putchar(*str);
                        str++;
                    }
                }break;
                case 'c':
                {
                    putchar(va_arg(arg_ptr,int));
                }break;
                default:break;
            }
        }
        else
        {
            putchar(*fmt);
        }
        fmt++;
    }
    va_end(arg_ptr);
    str=(char*)0;
}
```

- `my_scanf()`的实现

`my_scanf()`函数的实现基本与`my_printf`的实现是类似的，因此直接上代码

```c
void my_scanf(const char* fmt,...)
{
    va_list arg_ptr;
    int dec;
    int *d_ptr;
    char str[50];
    char *s_ptr;
    char *c;
    va_start(arg_ptr,fmt);
    while((*fmt)!='\0')
    {
        if(*fmt=='%')
        {
            fmt++;
            switch(*fmt)
            {
                case 'd':
                {
                    readcmd(str,16);//读取一个数字字符串
                    dec=atoi_c(str);//将字符串转为整数
                    d_ptr=va_arg(arg_ptr,int*);
                    *d_ptr=dec;//整数赋值
                }break;
                case 's':
                {
                    s_ptr=va_arg(arg_ptr,char*);
                    readcmd(s_ptr,16);//读取一个数字字符串
                }break;
                case 'c':
                {
                    c=va_arg(arg_ptr,char*);
                    readcmd(str,2);//读取一个字符（另外一个是回车）
                    *c=str[0];
                }break;
                default:break;
            }
            
        }
        else{

            }
            fmt++;
    }
    va_end(arg_ptr);
    s_ptr=(char*)0;
    d_ptr=(int*)0;
}
```

#### （14）c语言测试程序

编写完c语言的基本库后，需要编写一个调用该库的用户程序来进行测试。该用户程序仅需要`#include"stdio.h"`便可以直接调用里面的函数。我把该测试程序当成一个新加的用户程序，因此可以直接`run 6`就可以在虚拟机中调用。   具体的测试带代码如下：

```c
#include"stdio.h"
#define BUFLEN 16
#define NEXTLINE putchar('\r');putchar('\n')
int main()
{
    char *prin="your str is:\n";
    my_printf(prin);

    char str[50];
    int number;
    char *scan="%s%d";
    my_scanf(scan,str,&number);//测试my_scanf

    char* temp="str:%s,number:%d\n";
    my_printf(temp,str,number);//测试my_printf

    char str2[50]="test gets and puts:\n\r";
    puts(str2);//显示提示

    gets(str2);//测试gets
    puts(str2);//测试puts

    putchar('q');
    getch();
}
```

**注意：**用户程序的进入和退出是通过汇编来进行的，汇编的程序在`./usrprog/main.asm`。整个bin程序需要像内核一样进行混合编译链接。

```assembly
BITS 16
extern main
global _start 
_start:
    pusha
    mov	ax, cs                 ; 置其他段寄存器值与CS相同
    mov	ds, ax                 ; 数据段
    mov	es, ax                 ; 数据段
    call dword main		;直接调用c语言中的main函数
quit:
    popa
    retf								;调用完便退出
```

#### （15）程序的编译与整合

由于程序的编译以及整合是一个大量重复工作，因此我使用bash脚本来快速进行编译与整合，本次实验加上的文件有`sys_test.asm` `main.c `  `main.asm`  `system_c.c` `system_a.asm`，以及各个部分占用的扇区数以及偏移量已经改变

`combine.sh`

```bash
#!/bin/bash
rm -rf temp
mkdir temp
rm *.img

nasm booter.asm -o ./temp/booter.bin

cd usrprog
nasm topleft.asm -o ../temp/topleft.com
nasm topright.asm -o ../temp/topright.bin
nasm bottomleft.asm -o ../temp/bottomleft.bin
nasm bottomright.asm -o ../temp/bottomright.bin
nasm list.asm -o ../temp/list.bin
nasm sys_test.asm -o ../temp/sys_test.bin

cd c_test
nasm -f elf32 main.asm -o ../../temp/main_a.o
gcc -c -m16 -march=i386 -masm=intel -nostdlib -ffreestanding -mpreferred-stack-boundary=2 -lgcc -shared main.c -fno-pic  -o ../../temp/main_c.o
ld -m elf_i386 -N -Ttext 0xB900 --oformat binary ../../temp/main_a.o  ../../temp/main_c.o -o ../../temp/main.bin
cd ..

cd ..

cd lib
nasm -f elf32  system_a.asm -o ../temp/system_a.o
gcc -c -m16 -march=i386 -masm=intel -nostdlib -ffreestanding -mpreferred-stack-boundary=2 -lgcc -shared system_c.c -fno-pic  -o ../temp/system_c.o
cd ..
cd kernel
nasm -f elf32 kernel.asm -o ../temp/kernel.o
nasm -f elf32 kernel_a.asm -o ../temp/kernel_a.o
nasm -f elf32 ouch.asm -o ../temp/ouch.o
gcc -c -m16 -march=i386 -masm=intel -nostdlib -ffreestanding -mpreferred-stack-boundary=2 -lgcc -shared kernel_c.c -fno-pic  -o ../temp/kernel_c.o
ld -m elf_i386 -N -Ttext 0x7e00 --oformat binary ../temp/kernel.o ../temp/kernel_a.o ../temp/kernel_c.o  ../temp/ouch.o  ../temp/system_a.o ../temp/system_c.o  -o ../temp/kernel.bin
cd ..
rm ./temp/*.o

dd if=./temp/booter.bin of=myosv4.img bs=512 count=1 2>/dev/null
dd if=./temp/kernel.bin of=myosv4.img bs=512 seek=1 count=35 2>/dev/null
dd if=./temp/topleft.com of=myosv4.img bs=512 seek=36 count=2 2>/dev/null
dd if=./temp/topright.bin of=myosv4.img bs=512 seek=38 count=2 2>/dev/null
dd if=./temp/bottomleft.bin of=myosv4.img bs=512 seek=40 count=2 2>/dev/null
dd if=./temp/bottomright.bin of=myosv4.img bs=512 seek=42 count=2 2>/dev/null
dd if=./temp/list.bin of=myosv4.img bs=512 seek=44 count=2 2>/dev/null
dd if=./temp/main.bin of=myosv4.img bs=512 seek=46 count=24 2>/dev/null
dd if=./temp/sys_test.bin of=myosv4.img bs=512 seek=70 count=2 2>/dev/null
echo "[+] Done."
```

该脚本需要严格对应磁盘的放置，譬如`dd`时的扇区号，以及`ld`中`-Ttext 0x7E00`需要严格对照内存放置情况，不然会导致错误。

## 5.实验过程

### 1）踩坑过程

- `save` `restart`的实现

这次实验无疑最难的就是这两个寄存器的保护机制。save的过程是进入中断后将所有寄存器存储保护到结构体当中，restart是在中断退出前将结构体中所有寄存器还原回去，然后回到调用的程序当中。这样听起来思路好像很清晰，但是寄存器本身的作用会影响到这两个过程。譬如在restart的过程中需要用到一个辅助寄存器来把值还原，但是这个辅助寄存器也需要还原，所以就需要一个恢复的策略来准确的将所有寄存器都一个不漏保护起来，然后一个不漏地恢复回去

- `sp`寄存器的处理

在寄存器保护恢复的过程中，最为特别的就是`sp`寄存器了，因为我是使用压栈的操作来先进行保护所有寄存器的。因此`sp`寄存器在压栈后会有许多的变化。而且**最重要**的一个点就是在在中断进入后系统会将`psw`、`cs`、`ip `三个寄存器压栈。然后我在进入中断后，在`sp`压栈之前已经将8个寄存器压栈了。所以在`restart`过程中取出的`sp`寄存器是偏移了8+3个字的，所以在恢复的过程中，`sp`还需要+22。才能完全回到原来用户程序的`sp`

- 返回参数`ax`的保存

在系统调用（即中断）我都使用了save和restart来对寄存器进行保护，但是当我测试一个中断的时候发现数值并没有改变。这时我发现我的中断需要通过ax来将操作后的数值返回到用户程序当中。但是我的保护操作将ax寄存器原封不动的保护了起来，导致我的返回是没有用的。这时我想到一个办法就是，因为寄存器的restart是通过结构体上的值来恢复的，所以我就在restart操作之前将返回的ax值放进结构体上对应ax的位置上，这样restart的ax就是我需要的ax了

```assembly
    mov cx,ax
    push cx
    call dword getr1
    pop cx
    mov si, ax
    mov [cs:si+0],cx
```

- 可变参数函数的编写

本次实验的另一个难点就是`printf`和`scanf`函数的编写，因为之前还没有接触过可变参数函数的编写，所以一开始是不知所措的，但是通过网上搜一些资料后就发现，这个实现只需要调用一个头文件及其函数就可以逐个参数访问。


### 2）实验结果展示

- 首先进入开机画面（风火轮还在）

<img src="/home/biu/.config/Typora/typora-user-images/image-20200608100809391.png" alt="image-20200608100809391" style="zoom:75%;" />

- 点击`enter`进入命令行

<img src="/home/biu/.config/Typora/typora-user-images/image-20200608101132299.png" alt="image-20200608101132299" style="zoom:75%;" />

- 输入`run1432`逐个运行用户程序，发现和之前的运行是一样的，这里就不再截图展示了
- 输入`run 6`来测试c基本库函数的编写

<img src="/home/biu/.config/Typora/typora-user-images/image-20200608101308042.png" alt="image-20200608101308042" style="zoom:75%;" />

首先出现的是`your str is：`这个是通过下面代码输出的

```c
char *prin="your str is:\n";
    my_printf(prin);
```

<img src="/home/biu/.config/Typora/typora-user-images/image-20200608101355357.png" alt="image-20200608101355357" style="zoom:75%;" />

```c
char str[50];
    int number;
    char *scan="%s%d";
    my_scanf(scan,str,&number);//测试my_scanf
```

接下来便是`my_scanf`函数的输入，先输入一个字符串进入str，在输入数字进入number

<img src="/home/biu/.config/Typora/typora-user-images/image-20200608101647379.png" alt="image-20200608101647379" style="zoom:75%;" />

```c
char* temp="str:%s,number:%d\n";
    my_printf(temp,str,number);//测试my_printf
```

之后调用`my_printf`输出测试刚刚的输入是否成功

<img src="/home/biu/.config/Typora/typora-user-images/image-20200608101751279.png" alt="image-20200608101751279" style="zoom:75%;" />

```c
gets(str2);//测试gets
    puts(str2);
    putchar('q');
```

随后就是测试gets和puts

<img src="/home/biu/.config/Typora/typora-user-images/image-20200608101859988.png" alt="image-20200608101859988" style="zoom:75%;" />

可以看出编写的库函数的输入输出结果是正确的

- 系统调用的测试

首先输入`run 5`进入测试程序,此时字符串为`aaaBBBcccDDDeee`

<img src="/home/biu/.config/Typora/typora-user-images/image-20200608102103352.png" alt="image-20200608102103352" style="zoom:75%;" />

调用`00h`的变大写调用后（点击键盘任意键）：

<img src="/home/biu/.config/Typora/typora-user-images/image-20200608102247773.png" alt="image-20200608102247773" style="zoom:75%;" />

调用`01h`的变小写调用后（点击键盘任意键）：

<img src="/home/biu/.config/Typora/typora-user-images/image-20200608102315199.png" alt="image-20200608102315199" style="zoom:75%;" />

随后出现一个数字的字符串1229，调用`02h`将字符串转成数字（该过程看不到），但是将该数字+20，然后调用`03h`将数字转成字符串输出就可以看到出现1249，证明两个调用是成功的：

<img src="/home/biu/.config/Typora/typora-user-images/image-20200608102545859.png" alt="image-20200608102545859" style="zoom:75%;" />

测试`04h`输出字符串调用（点击键盘任意键）：

<img src="/home/biu/.config/Typora/typora-user-images/image-20200608102807246.png" alt="image-20200608102807246" style="zoom:75%;" />

可以看到出现字符串`using int21h`

之后测试`int 22h`,在屏幕某处显示`int 22H`（点击键盘任意键）：

<img src="/home/biu/.config/Typora/typora-user-images/image-20200608102922427.png" alt="image-20200608102922427" style="zoom:75%;" />

- 随后退出测试程序，输入`shutdown`关机

## 5.实验体会

​	本次实验五相较于之前的实验工程量是比较大的，可以从我完成本次实验后文件夹文件数目可以看出来这次实验的量是很大的，并且难度也比较大的。

​	懂得了系统调用的具体实现方法，因为内核的函数与用户程序是分开的，所以用户程序是不能直接访问内核中的函数的，所以需要专门指定一个中断号（`21h`）对应服务处理程序总入口，然后再将服务程序所有服务用功能号区分，并作为一个参数（通常是`ah`）从用户中传递过来，程序再进行分支，进入相应的功能实现子程序。

​	也懂得了如何在进入和退出中断对所有寄存器进行保护和恢复的过程。这两个函数的实现是本次实验里最为困难的部分，虽然脑子里有一点思路去进行，但是每次都是去尝试发现总有一些寄存器是没有保护恰当，导致程序运行失败。这才深刻理解到老师上课所说的“一个不漏，准确不误”是多么难实现。特别是sp寄存器的保护，因为栈的操作很多，导致sp寄存器的变化也是很多，最后保护需要的理解也要很到位。

​	虽然在本次实验之前我已经封装过不少的c语言库函数，但这次的实现更加的具体化，也实现了`printf` 和`scanf`两个最为常用的输入输出函数，最后测试成功的时候，成就感也是满满的

​	因为代码量也变得越来越多，占用的软盘空间也变大，这次实验使用到了1号柱面，这让我更清楚了解到软盘中柱面，磁头，扇区的对应关系。

​	总的来说，这次系统调用实验虽然困难险阻挺多的，但是在困难一个个解决过后，我对操作系统的理解也越来越深刻。

## 6.参考资料

- 系统调用的概念及原理：https://blog.csdn.net/qq_43646576/article/details/102841078
- 一个操作系统的实现——进程：https://blog.csdn.net/fukai555/article/details/41625619
- 可变参函数（my_printf可变参函数的实现）：https://blog.csdn.net/qq_39191122/article/details/79900720

