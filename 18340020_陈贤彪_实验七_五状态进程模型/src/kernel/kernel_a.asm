BITS 16
;%include"ouch.asm"

global clearScreen
global printInPos
global putchar_color
global getch
global getzifuchuan
global loadrun
global loadrun2
global getDateYear
global getDateMonth
global getDateDay
global getDateHour
global getDateMinute
global getDateSecond
global name
extern ouch
global shutdown

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
%macro LOADPRO 5       ;加载内存函数
    pusha            ; 保护现场
    mov ax,%1                  ; 段地址 ; 存放数据的内存基地址
    mov es,ax                  ; 设置段地址（不能直接mov es,段地址）
    mov bx, 0x0100    ; 偏移地址; 存放数据的内存偏移地址1
    mov ah,2                   ; 功能号
    mov al,%2                   ; 扇区数2
    mov dl,0                   ; 驱动器号 ; 软盘为0，硬盘和U盘为80H
    mov dh,%3                   ; 磁头号 ; 起始编号为0
    mov ch,%4                  ; 柱面号 ; 起始编号为0
    mov cl,%5                  ; 起始扇区号 ; 起始编号为3
    int 13H                    ; 调用读磁盘BIOS的13h功能
    popa             ; 恢复现场
%endmacro

%macro LOADPRO2 5       ;加载内存函数
    pusha            ; 保护现场
    mov ax,0                  ; 段地址 ; 存放数据的内存基地址
    mov es,ax                  ; 设置段地址（不能直接mov es,段地址）
    mov bx, %1    ; 偏移地址; 存放数据的内存偏移地址1
    mov ah,2                   ; 功能号
    mov al,%2                   ; 扇区数2
    mov dl,0                   ; 驱动器号 ; 软盘为0，硬盘和U盘为80H
    mov dh,%3                   ; 磁头号 ; 起始编号为0
    mov ch,%4                  ; 柱面号 ; 起始编号为0
    mov cl,%5                  ; 起始扇区号 ; 起始编号为3
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
    LOADPRO [bp+16],[bp],[bp+4],[bp+8],[bp+12]
    call dword pushCsIp    ; 用此技巧来手动压栈CS、IP
    pushCsIp:
    mov si, sp             ; si指向栈顶
    mov word[si], afterrun ; 修改栈中IP的值，这样用户程序返回回来后就可以继续执行了
    push word[bp+16]       ; 用户程序的段地址CS
    push 0100h       ; 用户程序的偏移量IP
   retf                   ; 段间跳转
   afterrun:
   popa
    retf
offset_program2 equ 0B900h

loadrun2:
   pusha
    mov bp, sp
    add bp,20;pusha的栈跳过
    ;call moveto    
    ;call write_vector_ouch
    LOADPRO2 offset_program2,[bp],[bp+4],[bp+8],[bp+12]
    call   dword offset_program2
    ;call moveback
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
global system_call
extern toupper_a
extern tolower_a
extern atoi_a
extern itoa_a
extern printInpos_a
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
extern t_flag
gettimeflag:
    mov ax,[cs:t_flag]
    ret
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

    iret
    system_table:
    dw toupper_a,tolower_a,atoi_a,itoa_a
    dw printInpos_a,gettimeflag
extern showint22
global system_call22
system_call22:  
    PUSHALL
    call save

    push ds
    push si
    mov si,cs
    mov ds,si
    mov si,ax
    shr si,8
    add si,si
    call [system_table22+si]
    mov cx,ax
    push cx
    call dword getr1
    pop cx
    mov si, ax
    mov [cs:si+0],cx

    pop si
    pop ds

    RESTART

    iret
    system_table22:
    dw showint22


extern getr1
save:
    pusha
    mov bp, sp
    add bp, 16+2                   ; 参数首地址

    call dword getr1
    mov di, ax
    mov ax, [bp]
    mov [cs:di], ax
    mov ax, [bp+2]
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
    mov ax, [bp+26]
    mov [cs:di+26], ax
    mov ax, [bp+28]
    mov [cs:di+28], ax
    mov ax, [bp+30]
    mov [cs:di+30], ax

    popa
    ret



DataArea:
    name db 'a123a123a123'
    times 16-($-name) db 0
