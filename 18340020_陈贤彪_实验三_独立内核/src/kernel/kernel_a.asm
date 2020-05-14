BITS 16

global clearScreen
global printInPos
global putchar
global getch
global getzifuchuan
global loadrun
global getDateYear
global getDateMonth
global getDateDay
global getDateHour
global getDateMinute
global getDateSecond
global name
%macro LOADPRO 4        ;加载内存函数
    pusha            ; 保护现场
    mov ax,cs                  ; 段地址 ; 存放数据的内存基地址
    mov es,ax                  ; 设置段地址（不能直接mov es,段地址）
    mov bx, %1    ; 偏移地址; 存放数据的内存偏移地址1
    mov ah,2                   ; 功能号
    mov al,%2                   ; 扇区数2
    mov dl,0                   ; 驱动器号 ; 软盘为0，硬盘和U盘为80H
    mov dh,%3                   ; 磁头号 ; 起始编号为0
    mov ch,0                   ; 柱面号 ; 起始编号为0
    mov cl,%4                  ; 起始扇区号 ; 起始编号为3
    int 13H                    ; 调用读磁盘BIOS的13h功能
    popa             ; 恢复现场
%endmacro

offset_proinf equ 7E00h    ; 用户程序信息表被装入的位置
offset_program1 equ 0B100h
clearScreen:               ; 函数：清屏
    push ax
    mov ax, 0003h
    int 10h                ; 中断调用，清屏
    pop ax
    retf

printInPos:                ; 函数：在指定位置显示字符串
    pusha                  ; 保护现场（压栈16字节）
    mov si, sp             ; 由于代码中要用到bp，因此使用si来为参数寻址
    add si, 16+4           ; 首个参数的地址
    mov	ax, cs             ; 置其他段寄存器值与CS相同
    mov	ds, ax             ; 数据段
    mov	bp, [si]           ; BP=当前串的偏移地址
    mov	ax, ds             ; ES:BP = 串地址
    mov	es, ax             ; 置ES=DS
    mov	cx, [si+4]         ; CX = 串长（=9）
    mov	ax, 1301h          ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
    mov	bx, 0007h          ; 页号为0(BH = 0) 黑底白字(BL = 07h)
    mov dh, [si+8]         ; 行号=0
    mov	dl, [si+12]        ; 列号=0
    int	10h                ; BIOS的10h功能：显示一行字符
    popa                   ; 恢复现场（出栈16字节）
    retf

putchar:                   ; 函数：在光标处打印一个字符
    pusha
    ;push bp
    mov bp, sp
    add bp, 16          ; 参数地址
    mov al, [bp+4]           ; al=要打印的字符
    mov bh, 0              ; bh=页码
    mov ah, 0Eh            ; 功能号：打印一个字符
    int 10h                ; 打印字符
    ;pop bp
    popa
    retf


getch:                     ; 函数：读取一个字符到tempc（无回显）
    mov ah, 0              ; 功能号
    int 16h                ; 读取字符，al=读到的字符
    ;mov ah, 0              ; 为返回值做准备
    retf

getDateYear:                    ; 函数：从CMOS获取当前年份
    mov al, 9
    out 70h, al
    in al, 71h
    mov ah, 0
    retf


getDateMonth:                   ; 函数：从CMOS获取当前月份
    mov al, 8
    out 70h, al
    in al, 71h
    mov ah, 0
    retf

getDateDay:                     ; 函数：从CMOS获取当前日期
    mov al, 7
    out 70h, al
    in al, 71h
    mov ah, 0
    retf

getDateHour:                    ; 函数：从CMOS获取当前小时
    ;pusha
    mov al, 4
    out 70h, al
    in al, 71h
    mov ah, 0
    ;popa
    retf


getDateMinute:                  ; 函数：从CMOS获取当前分钟
   ; pusha
    mov al, 2
    out 70h, al
    in al, 71h
    mov ah, 0
    ;popa
    retf

getDateSecond:                  ; 函数：从CMOS获取当前秒钟
    ;pusha
    mov al, 0
    out 70h, al
    in al, 71h
    mov ah, 0
   ; popa
    retf

getzifuchuan:
    mov ax,DataArea
    retf

loadrun:
   pusha

    mov bp, sp
    add bp,20
    LOADPRO offset_program1,2,[bp],[bp+4]
    ;LOADPRO 0xB00:100,2,[bp],[bp+4]
    call   dword offset_program1
    ;call    0B00h:100h

   popa
    retf


DataArea:
    name db 'a123a123a123'
    times 16-($-name) db 0
