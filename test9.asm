;屏幕显示80*25,即一个屏幕25行，一行80个字符
;显示缓冲区内存空间：B8000H~BFFFFH
;一个字符占两个字节：字符的ASSCII码和属性
;一行所需内存为80*2=160=A0H个字节
;从第11行中间开始显示，前十行内存需要：160*10=1600=640H Byte
;从11行32个字符显示：32*2+1=41H
;计算中间开始显示位置:B8000H+640H+41H=B8681H
;字符属性(一个字节)：Bl RGB I RGB（高亮 背景色 闪烁 前景色）
;绿色属性：(0000_0010B)02h、绿底红色：(0010_0100B)24H、白底蓝色:(0111_001B)71H
assume cs:code,ds:data,ss:stack
data segment
   str1 db 'Welcome to Masm!' ;要显示的字符
   property db 02H,24H,71H    ;三种颜色属性
data ends

stack segment
   dw 10 dup(0)
stack ends
code segment
start:
     mov ax,data
	 mov ds,ax
	 
	 mov ax,stack
	 mov ss,ax
	 mov sp,12H
	 
	 mov ax,0B868H
	 mov es,ax     ;es为11行中间显示起始位置
	 mov bx,0      ;要显示的第一行
	 mov cx,3      ;循环计数cx=3，要显示三行   
	 lea di,property ;当前属性     
s:
	 push cx       ;保护外层循环变量 
	 push di       ;保护属性地址
	 mov dl,ds:[di] ;取得属性值
	 lea si,str1   ;地址指针指向显示的字符起始地址  
	 mov dl,ds:[di] ;取得属性值
	 mov di,0      ;显示缓存区11行中间显示起始位置 
	 mov cx,16   ;要显示16个字符
s0:
	 mov al,ds:[si];取得要显示的字符
	 mov es:[bx+di],al ;先显示缓存区存入字符 
	 mov es:[bx+di+1],dl ;存入属性
	 inc si       ;下一个字符 
	 add di,2        ;显示缓存区下一个字符(一个字符两个字节)
	 loop s0       ;
	 add bx,160   ;要显示下一行的起始地址
	 pop di
	 inc di       ;下一个属性地址
	 pop cx
	 loop s
exit:
     mov ax,4c00h
	 int 21h
code ends
end start
