BITS 16
;%include"ouch.asm"

global clearScreen
global printInPos
;global putchar
global putchar_color
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
extern ouch
global shutdown
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

;offset_proinf equ 7E00h    
offset_program1 equ 0B100h; 用户程序信息表被装入的位置
clearScreen:               ; 清屏
    push ax
    mov ax, 0003h
    int 10h                ; 中断调用，清屏
    pop ax
    retf

shutdown:
    pusha
    mov ax,5307h
    mov bx,0001h
    mov cx,0003h
    int 15h
    popa
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

getDateYear:                    
    mov al, 9
    out 70h, al
    in al, 71h
    mov ah, 0
    retf


getDateMonth:                   
    mov al, 8
    out 70h, al
    in al, 71h
    mov ah, 0
    retf

getDateDay:                   
    mov al, 7
    out 70h, al
    in al, 71h
    mov ah, 0
    retf

getDateHour:              

    mov al, 4
    out 70h, al
    in al, 71h
    mov ah, 0

    retf


getDateMinute:   
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

%macro MOVE_INT_VECTOR 2        ; 将参数1的中断向量转移至参数2处
    push ax
    push es
    push si
    mov ax, 0
    mov es, ax
    mov si, [es:%1*4]
    mov [es:%2*4], si
    mov si, [es:%1*4+2]
    mov [es:%2*4+2], si
    pop si
    pop es
    pop ax
%endmacro

loadrun:
   pusha

    mov bp, sp
    add bp,20;pusha的栈跳过
    call moveto    
    call write_vector_ouch
    LOADPRO offset_program1,2,[bp],[bp+4]
    
    call   dword offset_program1
    call moveback
   popa
    retf
moveto:
    push ax
    push es
    push si
    mov ax, 0
    mov es, ax
    mov si, [es:09h*4]
    mov [es:37h*4], si
    mov si, [es:09h*4+2]
    mov [es:37h*4+2], si
    pop si
    pop es
    pop ax
    ret
moveback:
    push ax
    push es
    push si
    mov ax, 0
    mov es, ax
    mov si, [es:37h*4]
    mov [es:09h*4], si
    mov si, [es:37h*4+2]
    mov [es:09h*4+2], si
    pop si
    pop es
    pop ax
    ret
write_vector_ouch:
    pusha
    xor ax,ax			; AX = 0
	mov es,ax			; ES = 0
	mov word [es:09h*4],ouch	; 设置时钟中断向量的偏移地址
	mov ax,cs 
	mov word [es:09h*4+2],ax		; 设置时钟中断向量的段地址=CS
	mov ds,ax			; DS = CS
	mov es,ax			; ES = CS
    popa
    ret

DataArea:
    name db 'a123a123a123'
    times 16-($-name) db 0
