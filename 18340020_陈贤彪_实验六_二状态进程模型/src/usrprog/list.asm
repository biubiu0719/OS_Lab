offset_list equ 0B100h
;org offset_list
org 0100h
%macro PRINT 4
    pusha            ; 保护现场
    mov	ax, cs       ; 置其他段寄存器值与CS相同
    mov	ds, ax       ; 数据段
    mov	bp, %1       ; BP=当前串的偏移地址
    mov	ax, ds       ; ES:BP = 串地址
    mov	es, ax       ; 置ES=DS
    mov	cx, %2       ; CX = 串长（=9）
    mov	ax, 1301h    ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
    mov	bx, 0007h    ; 页号为0(BH = 0) 黑底白字(BL = 07h)
    mov dh, %3       ; 行号=0
    mov	dl, %4       ; 列号=0
    int	10h          ; BIOS的10h功能：显示一行字符
    popa             ; 恢复现场
%endmacro

start:
    pusha
    push ds
    call ClearScreen
    PRINT title, titlelen, 0, 0
    PRINT pro1, pro1len, 1, 0
    PRINT pro2, pro2len, 2, 0
    PRINT pro3, pro3len, 3, 0
    PRINT pro4, pro4len, 4, 0
    PRINT hint1, hint1len, 16, 0
loop:
    mov ah, 0;
    int 16h
    cmp al, 27; 按下esc
    je back
    jmp loop


back:
pop ds
    popa
    retf

ClearScreen:         ; 函数：清屏
    pusha
    mov ax, 0003h
    int 10h          ; 中断调用，清屏
    popa
    ret


DataArea:
    title db'name       head        cylinder        start_sector        size'
    titlelen equ ($-title)
    pro1 db 'pro1       1           0               1                   1024'
    pro1len equ ($-pro1)
    pro2 db 'pro2       1           0               3                   1024'
    pro2len equ ($-pro2)
    pro3 db 'pro3       1           0               5                   1024'
    pro3len equ ($-pro3)
    pro4 db 'pro4       1           0               7                   1024'
    pro4len equ ($-pro4)

    hint1 db 'Press ESC to exit.'
    hint1len equ ($-hint1)
SectorEnding:
    times 1024-($-$$) db 0

