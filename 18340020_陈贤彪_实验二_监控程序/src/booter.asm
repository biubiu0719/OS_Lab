offset_booter equ 7C00h       ;512字节为00200h
offset_program1 equ 8100h      ;+00200h
offset_program2 equ 8100h      ;+00400h
offset_program3 equ 8100h      ;+00400h
offset_program4 equ 8100h      ;+00400h
offset_list equ 8300h
; 用于在指定位置显示字符串，参数：(字符串首地址, 字符串字节数, 行数, 列数)
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
%macro LOADPRO 3        ;加载内存函数
    pusha            ; 保护现场
    mov ax,cs                  ; 段地址 ; 存放数据的内存基地址
    mov es,ax                  ; 设置段地址（不能直接mov es,段地址）
    mov bx, %1    ; 偏移地址; 存放数据的内存偏移地址1
    mov ah,2                   ; 功能号
    mov al,%2                   ; 扇区数2
    mov dl,0                   ; 驱动器号 ; 软盘为0，硬盘和U盘为80H
    mov dh,0                   ; 磁头号 ; 起始编号为0
    mov ch,0                   ; 柱面号 ; 起始编号为0
    mov cl,%3                  ; 起始扇区号 ; 起始编号为3
    int 13H                    ; 调用读磁盘BIOS的13h功能
    popa             ; 恢复现场
%endmacro

org  7C00h                     ; BIOS将把引导扇区加载到0:7C00h处，并开始执行


start:
    mov	ax, cs                 ; 置其他段寄存器值与CS相同
    mov	ds, ax                 ; 数据段
    mov	bp, Message            ; BP=当前串的偏移地址
    mov	ax, ds                 ; ES:BP = 串地址
    mov	es, ax                 ; 置ES=DS
    mov	cx, msglen             ; CX = 串长（=9）
    mov	ax, 1301h              ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
    mov	bx, 0007h              ; 页号为0(BH = 0) 黑底白字(BL = 07h)
    mov dh, 0                  ; 行号=0
    mov	dl, 0                  ; 列号=0
    int	10h                    ; BIOS的10h功能：显示一行字符

start1:
    call ClearScreen ; 清屏
    PRINT xinxi, xinxilen, 0, 0
    PRINT hint, hintlen, 1, 0

Keyboard:
    mov ah, 0; Bochs: 0000:a173
    int 16h
    cmp al, 'a'; 按下1
    jne noload1
mov ax, cs       ; 置其他段寄存器值与CS相同
    mov	ds, ax       ; 数据段
    mov es,ax
    mov ss,ax
    LOADPRO offset_program1,1,2;加载program1到内存
    jmp 800h:100h
    ;jmp offset_program1   ; 执行用户程序1
noload1:
    cmp al, 'b'; 按下2
    jne noload2
    LOADPRO offset_program2,1,3;加载program2到内存
    ;jmp offset_program2   ; 执行用户程序2
    call 800h:100h
noload2:
    cmp al, 'c'; 按下3
    jne noload3
    LOADPRO offset_program3,1,4;加载program3到内存
    jmp offset_program3   ; 执行用户程序3
    ;call 800h:100h
noload3:
    cmp al, 'd'; 按下4
    jne noload4
    LOADPRO offset_program4,1,5;加载program3到内存
    ;jmp offset_program4   ; 执行用户程序4
    call  0:8100h
noload4:
    cmp al, 'l'; 按下4
    jne noloadl
    LOADPRO offset_list,2,6;加载program3到内存
    jmp offset_list
noloadl:
    mov al,0
    jmp start1


AfterRun:
   jmp $                      ; 无限循环

ClearScreen:         ; 函数：清屏
    pusha
    mov ax, 0003h
    int 10h          ; 中断调用，清屏
    popa
    ret
DataArea:
    Message db 'Hello, MyOs is loading user program A.COM… '
    msglen  equ ($-Message)

    xinxi db 'Chen Xianbiao, 18340020'
    xinxilen equ ($-xinxi)


    hint db 'Press  (a/b/c/d) to run! or press l to look at the programlist'
    hintlen equ ($-hint)


SectorEnding:
    times 510-($-$$) db 0
    db 0x55,0xaa
