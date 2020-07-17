
[global _start]
org 100h
%macro PRINTLN 1
    pusha
    mov si, %1
Loop1_%1:
    cmp byte[cs:si], 0
    je Quit1_%1
    PUTCHAR [cs:si]
    inc si
    jmp Loop1_%1
Quit1_%1:
    popa
%endmacro

%macro PUTCHAR 1
    pusha
    mov al, %1   ; al=要打印的字符
    mov bh, 0      ; bh=页码
    mov ah, 0Eh    ; 功能号：打印一个字符
    int 10h        ; 打印字符
    popa
%endmacro
 delay equ 8000
_start:
    mov ax, 0003h
    int 10h                    ; 清屏
    PRINTLN welcome            ; 打印欢迎信息
    mov word[count1],delay
    mov word[count2],delay
    int 22h                    ; 调用fork()，ax=fork的结果
    cmp ax, 0
    jl ForkFailure
    cmp ax, 0
    jg ForkParent
    cmp ax, 0
    je ForkSon

    jmp QuitUsrProg


ForkFailure:                   ; ------ fork失败 ------
    PRINTLN error_fork
    jmp QuitUsrProg




ForkSon:                       ; ------ 子进程 ------
    loopdraw:
    ;sleep2:
    ;dec word[count2]
    ;jnz sleep2

    int 25h
    mov word[count2],delay
    mov ax,word[bankbalance]
    dec ax
    sleep22:
    dec word[count2]
    jnz sleep22
    mov word[count2],delay
    mov word[bankbalance],ax
    ;dec word[bankbalance]
    inc word[drawmoney]
    
    
    PRINTLN son_say1
    call printbalanceCount
    
    PRINTLN son_say2
    call printdrawCount
    int 26h
    cmp word[drawmoney],10
    je QuitUsrProg2

    jmp loopdraw

ForkParent:                    ; ------ 父进程 ------
    ;int 23h
    loopsave:
    ;sleep1:
    ;dec word[count1]
    ;jnz sleep1
    ;mov word[count1],delay
    int 25h
    mov ax,word[bankbalance]
    inc ax
    sleep11:
    dec word[count1]
    jnz sleep11
mov word[count1],delay
    mov word[bankbalance],ax
    ;inc word[bankbalance]
    inc word[savemoney]
    
    
    PRINTLN parent_say1
    call printbalanceCount
    
    PRINTLN parent_say2
    call printsaveCount
    

    int 26h
    cmp word[savemoney],10
    je QuitUsrProg

    jmp loopsave

QuitUsrProg2:
    ;int 24h
    jmp $

QuitUsrProg:
    jmp $



printbalanceCount:              ; 函数：打印letter_count（默认为两位数）
    pusha
    mov ax, [bankbalance]
    mov bl, 10
    div bl                     ; al = ax/ah, ah = ax%ah
    add al, '0'                ; 十位数的ASCII
    add ah, '0'                ; 个位数的ASCII
    PUTCHAR al                 ; 打印十位数
    PUTCHAR ah                 ; 打印个位数
    popa
    
    ret

printsaveCount:
    pusha
    mov ax, [savemoney]
    mov bl, 10
    div bl                     ; al = ax/ah, ah = ax%ah
    add al, '0'                ; 十位数的ASCII
    add ah, '0'                ; 个位数的ASCII
    PUTCHAR al                 ; 打印十位数
    PUTCHAR ah                 ; 打印个位数
    popa
    ret

printdrawCount:
    pusha
    mov ax, [drawmoney]
    mov bl, 10
    div bl                     ; al = ax/ah, ah = ax%ah
    add al, '0'                ; 十位数的ASCII
    add ah, '0'                ; 个位数的ASCII
    PUTCHAR al                 ; 打印十位数
    PUTCHAR ah                 ; 打印个位数
    popa
    ret

DataArea:
    count1 dw delay
    count2 dw delay
    bankbalance dw 50          ; 用于存放字母个数的全局变量
    savemoney dw 0
    drawmoney dw 0
    welcome db 'This is the `pv_test`programme.', 0Dh, 0Ah, 0
    error_fork db 'Error in fork! Press ESC to quit.', 0Dh, 0Ah, 0
    parent_say1 db 0Dh, 0Ah,
                                db 'Parent : bankbalance=',0
    parent_say2 db '    totalsave= ',0
    son_say1 db 0Dh, 0Ah,
                        db 'Child : bankbalance=',0
    son_say2 db '    totaldraw= ',0

    finishbye db  0Dh, 0Ah, 0Dh, 0Ah,
        db 'Please Press ESC to quit.'
times 1024-($-$$) db 0 ; 