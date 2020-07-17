BITS 16
extern main
global _start 
_start:
    pusha
    push ds
    mov	ax, cs                 ; 置其他段寄存器值与CS相同
    mov	ds, ax                 ; 数据段
    mov	es, ax                 ; 数据段
again:
    call dword main
quit:
    pop ds
    popa
    retf

global printInPos
global putchar_color
global getch
global clearScreen

clearScreen:               ; 清屏
    push ax
    mov ax, 0003h
    int 10h                ; 中断调用，清屏
    pop ax
    retf

printInPos:               
    pusha                  ; 保护现场（压栈16字节）
    mov si, sp             ; 由于代码中要用到bp，因此使用si来为参数寻址
    add si, 16+4           ; ;pusha的栈跳过，4位第一个参数
    mov	ax, cs            
    mov	ds, ax           
    mov	bp, [si]         
    mov	ax, ds           
    mov	es, ax             
    mov	cx, [si+4]         
    mov	ax, 1301h       
    mov	bx, 0007h        
    mov dh, [si+8]         
    mov	dl, [si+12]      
    int	10h                
    popa                   
    retf

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

getch:                     ; 读取一个字符
    mov ah, 0              ; 功能号
    int 16h                ; 读取字符，al=读到的字符
    retf
