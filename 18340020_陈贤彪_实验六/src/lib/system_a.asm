BITS 16
global toupper_a
global tolower_a
global atoi_a
global itoa_a
global showint22
global printInpos_a
%macro PRINT 4
    pusha            ; 保护现场
    mov	ax, cs       ; 置其他段寄存器值与CS相同
    mov	ds, ax       ; 数据段
    mov	bp, %1       ; BP=当前串的偏移地址
    mov	ax, ds       ; ES:BP = 串地址
    mov	es, ax       ; 置ES=DS
    mov	cx, %2       ; CX = 串长（=9）
    mov	ax, 1301h    ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
    mov	bx, 0009h    ; 页号为0(BH = 0) 黑底白字(BL = 07h)
    mov dh, %3       ; 行号=0
    mov	dl, %4       ; 列号=0
    int	10h          ; BIOS的10h功能：显示一行字符
    popa             ; 恢复现场
%endmacro
showint22:
    pusha
    PRINT strint22,strint22_len,13,20
    popa
    ret
data1:
    strint22 db 'int 22H'
    strint22_len equ ($-strint22)

extern toupper_c
toupper_a:
    push es           ; 传递参数
    push dx           ; 传递参数
    call dword toupper_c
    pop dx            ; 丢弃参数
    pop es            ; 丢弃参数
    ret
extern tolower_c
tolower_a:
    push es           ; 传递参数
    push dx           ; 传递参数
    call dword tolower_c
    pop dx            ; 丢弃参数
    pop es            ; 丢弃参数
    ret

extern atoi_c
atoi_a:
    push es           ; 传递参数;
    push dx           ; 传递参数
    call dword atoi_c
    pop dx            ; 丢弃参数
    pop es            ; 丢弃参数
    ret

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
