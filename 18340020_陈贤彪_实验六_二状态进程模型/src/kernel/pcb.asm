BITS 16

%macro LOADPROM 5       ;加载内存函数
    pusha            ; 保护现场
    mov ax,%1                  ; 段地址 ; 存放数据的内存基地址
    mov es,ax                  ; 设置段地址（不能直接mov es,段地址）
    mov bx, 0000h    ; 偏移地址; 存放数据的内存偏移地址1
    mov ah,2                   ; 功能号
    mov al,%2                   ; 扇区数2
    mov dl,0                   ; 驱动器号 ; 软盘为0，硬盘和U盘为80H
    mov dh,%3                   ; 磁头号 ; 起始编号为0
    mov ch,%4                  ; 柱面号 ; 起始编号为0
    mov cl,%5                  ; 起始扇区号 ; 起始编号为3
    int 13H                    ; 调用读磁盘BIOS的13h功能
    popa             ; 恢复现场
%endmacro

%macro  PUSHALLPCB 0
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
    mov ax,cs
    mov ds,ax
    mov es,ax
%endmacro
extern getfirstpcb
global t_flag
extern getcurrentpcb
%macro  RESTARTPCB 0              ; 宏：从PCB中恢复寄存器的值
    call dword getcurrentpcb
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

pcbsave:
    pusha
    mov bp, sp
    add bp, 16+2                   ; 参数首地址

    call dword getcurrentpcb
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
    
extern schedule
extern reset
global pcbtimer
pcbtimer:
    ;pusha
    cmp word[cs:t_flag], 0
    je timequit

    PUSHALLPCB
    call pcbsave
    add sp, 16*2  ;丢弃栈中参数
checkesc:
    mov ah ,01h
    int 16h
    jz continuetimer
    mov ah,0
    int 16h
    cmp al,27
    jne continuetimer

  call dword reset
    jmp restart
    
continuetimer:
    call dword schedule


restart:
    RESTARTPCB
timequit:
wudifenghuolun:
    pusha
    push ds
    push gs;压栈保护寄存器
    xor ax,ax
    mov ax,cs
    mov ds,ax                   ; DS = CS
    mov	ax,0B800h               ; 文本窗口显存起始地址
    mov	gs,ax                   ; GS = B800h

    dec byte[count];增加延迟使效果更好
    jnz end
    mov byte[count],delay
    mov ah,0Fh
    mov si,fenghuolun;取字符串首地址
    add si,[fenghuoluncount];然后加上偏移量
    inc byte[fenghuoluncount];偏移量+1
    mov al,[si]	
    mov [gs:((80*24+79)*2)],ax;右下角
    mov [gs:((80*0+79)*2)],ax;右上角
    mov [gs:((80*24+0)*2)],ax;左下角
    cmp byte[fenghuoluncount],4
    jne end
    mov byte[fenghuoluncount],0
    



end:
    pop gs
    pop ds
    popa
    push ax
    mov al, 20h
    out 20h, al
    out 0A0h, al
    pop ax
    ;popa
    iret


global loadm
loadm:
   pusha
    mov bp, sp
    add bp,20;pusha的栈跳过
    LOADPROM [bp+16],[bp],[bp+4],[bp+8],[bp+12]
   popa
    retf


area:
    t_flag dw 0
    delay equ 3
    count db delay
    fenghuolun db '\|/-'
    fenghuoluncount dw 0 