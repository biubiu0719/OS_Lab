BITS 16
global ouch
ouch:
    pusha
    push es
    push ds

    xor ax,ax
    mov ax,cs 
    mov ds,ax
    mov	bp, ouch_mess     ; BP=当前串的偏移地址
    mov	ax, ds           ; ES:BP = 串地址
    mov	es, ax           ; 置ES=DS
    mov	cx, ouch_mess_len ; CX = 串长
    mov	ax, 1300h        ; AH = 13h（功能号）、AL = 00h（光标不动）
    mov	bx, 0007h        ; 页号为0(BH = 0) 黑底白字(BL = 07h)
    mov dh, 13           ; 行号=0
    mov	dl, 31           ; 列号=0
    int	10h              ; BIOS的10h功能：显示一行字符

loopdelay:
    dec word[count]
    jnz loopdelay
    mov word[count],delay
    dec word[dcount]
    jnz loopdelay
    mov word[count],delay
    mov word[dcount],ddelay

   mov	ax, cs           ; 置其他段寄存器值与CS相同
    mov	ds, ax           ; 数据段
    mov	bp, kongbai   ; BP=当前串的偏移地址
    mov	ax, ds           ; ES:BP = 串地址
    mov	es, ax           ; 置ES=DS
    mov	cx,ouch_mess_len ; CX = 串长
    mov	ax, 1300h        ; AH = 13h（功能号）、AL = 00h（光标不动）
    mov	bx, 0007h        ; 页号为0(BH = 0) 黑底白字(BL = 07h)
    mov dh, 13           ; 行号=0
    mov	dl, 31           ; 列号=0
    int	10h              ; BIOS的10h功能：显示一行字符
    
   int 37h              ; 调用原来的键盘中断

    mov al,20h           ; AL = EOI
    out 20h,al           ; 发送EOI到主8529A
    out 0A0h,al          ; 发送EOI到从8529A

    pop ds
    pop es
    popa
    iret

data:
    delay equ 55000
    ddelay equ 580
    count dw delay
    dcount dw ddelay
    ouch_mess db 'Ouch!Ouch!'
    ouch_mess_len equ ($-ouch_mess)
    kongbai db '          '