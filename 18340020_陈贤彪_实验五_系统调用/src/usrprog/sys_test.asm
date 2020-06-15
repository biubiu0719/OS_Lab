offset_sys_test equ 0B100h      

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

org offset_sys_test
start:
    pusha
    push es
    call ClearScreen
    PRINT hint1,hint1_len,0,0
    PRINT hint2,hint2_len,15,0
    PRINT string,string_len,3,15

    mov ah,0
    int 16h
    cmp al,27
    je quit
    
test_upper:
    mov ax,cs
    mov es,ax
    mov dx,string
    mov ah,00h
    int 21h
    PRINT string,string_len,3,15

    mov ah,0
    int 16h
    cmp al,27
    je quit
test_lower:
    mov ax,cs
    mov es,ax
    mov dx,string
    mov ah,01h
    int 21h
    PRINT string,string_len,3,15

    mov ah,0
    int 16h
    cmp al,27
    je quit
    PRINT num_str,num_str_len,5,15
    
test_atoi:
    mov ax,cs
    mov es,ax
    mov dx,num_str
    mov ah,02h
    int 21h
    mov bx,ax
    add bx,20

    mov ah,0
    int 16h
    cmp al,27
    je quit

test_itoa:
    mov ax,cs
    mov es,ax
    mov dx,num_str
    mov ah,03h
    int 21h
    PRINT num_str,num_str_len,5,15

    mov ah,0
    int 16h
    cmp al,27
    je quit

test_print:
  mov ax,cs
  mov es,ax
    mov dx,test_print_str
    mov ch, 12
    mov cl, 40
   mov ah, 04h
    int 21h                            ; 显示第二条字符串

    mov ah,0
  int 16h
   cmp al,27
    je quit
test_int22:
    mov ah,00h
    int 22h

    mov ah,0
    int 16h
    cmp al,27
    je quit

quit:
    pop es
    popa
    retf

ClearScreen:               ; 函数：清屏
    pusha
    mov ax, 0003h
    int 10h                ; 中断调用，清屏
    popa
    ret


Data_area:
    hint1 db 'this is the tester od systemcaller'
    hint1_len equ ($-hint1)
    hint2 db 'please press any keys to continue,or press ESC to exit'
    hint2_len equ ($-hint2)
    string db 'aaaBBBcccDDDeee'
    string_len equ ($-string)
    test_print_str db 'using  `int 21h`.',0
   num_str_test equ ($-test_print_str)
   num_str db '1229'
    num_str_len equ ($-num_str)
    
   
times 1024-($-$$) db 0 ; 填充0，一直到第1024字节