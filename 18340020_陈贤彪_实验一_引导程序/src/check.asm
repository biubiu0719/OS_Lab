Dn_Rt equ 1                  ;D-Down,U-Up,R-right,L-Left
Up_Rt equ 2                  ;
Up_Lt equ 3                  ;
Dn_Lt equ 4   
delay equ 50000					; 计时器延迟计数,用于控制画框的速度
ddelay equ 500					; 计时器延迟计数,用于控制画框的速度
org 7c00h
	xor ax,ax
	mov ax,cs
	mov es,ax
	mov ds,ax
	mov ax,0xb800
	mov es,ax
;初始化变量
	mov byte[char],'a'	
	mov word[x],1
	mov word[y],0
	mov byte[rudl],1
                mov byte[color],0x07	
;打印学号姓名
        	mov byte [es:0x00],'1'
	mov byte [es:0x01],0x07
        	mov byte [es:0x02],'8'
	mov byte [es:0x03],0x07
        	mov byte [es:0x04],'3'
         	mov byte [es:0x05],0x07
         	mov byte [es:0x06],'4'
         	mov byte [es:0x07],0x07
	 mov byte [es:0x08],'0'
         	mov byte [es:0x09],0x07
         	mov byte [es:0x0a],'0'
         	mov byte [es:0x0b],0x07
        	mov byte [es:0x0c],'2'
         	mov byte [es:0x0d],0x07
         	mov byte [es:0x0e],'0'
         	;mov byte [es:0x0f],0x07
	;mov byte [es:0x10],'c'
         	;mov byte [es:0x11],0x07
        	;mov byte [es:0x12],'x'
         	;mov byte [es:0x13],0x07
         	;mov byte [es:0x14],'b'
         	;mov byte [es:0x15],0x07
		

loop1:
	
	dec word[count]
	jnz loop1
	mov word[count],delay
	dec word[dcount]
	jnz loop1
	mov word[count],delay
	mov word[dcount],ddelay

	mov al,1	
	cmp al,byte[rudl]
		jz DnRt
	mov al,2
	cmp al,byte[rudl]
		jz UpRt
	mov al,3
	cmp al,byte[rudl]
		jz UpLt
	mov al,4
	cmp al,byte[rudl]
		jz DnLt
			jmp $

DnRt:
	inc word[x]
	inc word[y]
	mov bx,word[x]
	mov ax,25
	sub ax,bx
		jz dr2ur
	mov bx,word[y]
	mov ax,80
	sub ax,bx
     		jz  dr2dl
			jmp show
dr2ur:
      mov word[x],24
      mov byte[rudl],2	
      jmp show

dr2dl:
      mov word[y],79
      mov byte[rudl],4	
      jmp show

UpRt:
	dec word[x]
	inc word[y]
	mov bx,word[y]
	mov ax,80
	sub ax,bx
      		jz  ur2ul
	mov bx,word[x]
	mov ax,-1
	sub ax,bx
      		jz  ur2dr
			jmp show
ur2ul:
      mov word[y],79
      mov byte[rudl],Up_Lt	
      jmp show
ur2dr:
      mov word[x],1
      mov byte[rudl],Dn_Rt	
      jmp show


UpLt:
	dec word[x]
	dec word[y]
	mov bx,word[x]
	mov ax,-1
	sub ax,bx
     		 jz  ul2dl
	mov bx,word[y]
	mov ax,-1
	sub ax,bx
      		jz  ul2ur
			jmp show

ul2dl:
      mov word[x],1
      mov byte[rudl],Dn_Lt	
      jmp show
ul2ur:
      mov word[y],1
      mov byte[rudl],Up_Rt	
      jmp show

DnLt:
	inc word[x]
	dec word[y]
	mov bx,word[y]
	mov ax,-1
	sub ax,bx
      		jz  dl2dr
	mov bx,word[x]
	mov ax,25
	sub ax,bx
     		 jz  dl2ul
			jmp show

dl2dr:
      	mov word[y],0
      	mov byte[rudl],Dn_Rt	
      	jmp show
	
dl2ul:
      	mov word[x],24
      	mov byte[rudl],Up_Lt	
      	jmp show


show:	
     	xor ax,ax                 ; 计算显存地址
      	mov ax,word[x]
	mov bx,80
	mul bx
	add ax,word[y]
	mov bx,2
	mul bx
	mov bx,ax                	
	inc byte[color]
                inc byte[char]
	mov ah,byte[color]				;  0000：黑底、1111：亮白字（默认值为07h）
	mov al,byte[char]			;  AL = 显示字符值（默认值为20h=空格符）
	mov [es:bx],ax  		;  显示字符的ASCII码值
	;mov byte[es:bx],'a'
	;mov byte[es:bx+1],0x07
	jmp loop1



datadef:	
	count dw delay
	dcount dw ddelay
	rudl db 1         ; 向右下运动
	x    dw 2
	y    dw 3
	char db '@'
	color db 7
 times 510-( $-$$ ) db 0

    db 0x55, 0xaa
