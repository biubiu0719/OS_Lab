
BITS 16

extern startos
extern cmd           ;汇编调用c函数的方式
extern system_call
extern system_call22
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

global _start              ;让c调用汇编的方式必须 _start
_start:
    mov	ax, cs                 ; 置其他段寄存器值与CS相同
    mov	ds, ax                 ; 数据段
    mov	es, ax                 ; 数据段
    ;call dword write_vector_timer
    
    WRITE_INT_VECTOR 08h,wudifenghuolun
    WRITE_INT_VECTOR 21h, system_call
    WRITE_INT_VECTOR 22h, system_call22
    call dword startos


loop1:
    mov	ax, cs                 ; 置其他段寄存器值与CS相同
    mov	ds, ax                 ; 数据段
    mov	es, ax                 ; 数据段
    mov ah, 0
    int 16h
    cmp al, 0dh      ; 按下回车
    jne loop1     
    call   dword cmd ; 进入命令行界面
    jmp loop1

  write_vector_timer:
    pusha
    xor ax,ax			; AX = 0
	mov es,ax			; ES = 0
	mov word [es:20h],wudifenghuolun	; 设置时钟中断向量的偏移地址
	mov ax,cs 
	mov word [es:22h],ax		; 设置时钟中断向量的段地址=CS
	mov ds,ax			; DS = CS
	mov es,ax			; ES = CS
    popa
    ret

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
    mov byte[fenghuoluncount],0;若偏移量达到4，则变回0
end:
    mov al,20h                  ; AL = EOI
    out 20h,al                  ; 发送EOI到主8529A
    out 0A0h,al                 ; 发送EOI到从8529A   
    pop gs
    pop ds;出栈
    popa
    iret

Data:
    delay equ 1
    count db delay
    fenghuolun db '\|/-'
    fenghuoluncount dw 0 