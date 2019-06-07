DATASEG
label __util__def
rando_x dw -9127 
rando_y dw -671
CODESEG
macro draw_pixel x,y,color
    push ax
    push bx
    push cx
    push dx
    mov al, color
    mov ah, 0ch
    xor bh,bh
    mov cx, x
    mov dx, y
    int 10h
    pop dx
    pop cx
    pop bx
    pop ax
endm draw_pixel

macro printchar char
    push ax
    push dx

    mov dl, char
    mov ah, 2h
    int 21h

    pop dx
    pop ax
endm printchar

proc printuint
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    mov ax, [bp+4]
    mov cx, 5
    get_loop2:
        mov bx, 10
        xor dx,dx
        div bx
        push dx
        dec cx
        cmp cx, 0
        jne get_loop2
    mov cx, 5
    mov si, 0
    print_loop2:
        pop ax
        cmp ax, 0
        jne print_d2
        cmp si, 0
        jne print_d2
        jmp next_digit2
        print_d2:
            mov si, 1
            add ax, 30h
            printchar <al>
        next_digit2:
        dec cx
        cmp cx, 0
        jne print_loop2
    cmp [word bp+4],0
    jne dropl2
        printchar '0'
    dropl2:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 2
endp printuint

proc printint
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    mov ax, [bp+4]
    shl ax, 1
    jnc prep_print
        printchar '-'
        mov bx, ax
        and bx, 0111111111111111b
        mov ax, [bp+4]
        sub ax, bx
        shl ax, 1
    prep_print:
    shr ax, 1
    mov cx, 5
    get_loop:
        mov bx, 10
        xor dx,dx
        div bx
        push dx
        dec cx
        cmp cx, 0
        jne get_loop
    mov cx, 5
    mov si, 0
    print_loop:
        pop ax
        cmp ax, 0
        jne print_d
        cmp si, 0
        jne print_d
        jmp next_digit
        print_d:
            mov si, 1
            add ax, 30h
            printchar <al>
        next_digit:
        dec cx
        cmp cx, 0
        jne print_loop
    cmp [word bp+4],0
    jne dropl
        printchar '0'
    dropl:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 2
endp printint

proc playstring
	push bp
	mov bp,sp
	
	push di
	push bx
	
	xor di,di
	mov bx,[bp+4]
	cmp [word bx], 0
	je end_while
	while_nz:
	
		push 0
		push [bp+6]
		push [bx+di]
		call playsound
	
		inc di
		cmp [word bx+di], 0
		jne while_nz
	end_while:
	pop bx
	pop di
	pop bp
	ret 4
endp playstring

proc playsound
	push bp
	mov bp, sp
	push ax
	
	mov al,183			;prepare for node
	out 43h, al
	
	mov ax, [bp+4]
	
	out 42h, al
	mov al, ah
	out 42h, al
	
	
	
	in al, 61h			;open speaker
	or al, 11b
	out 61h, al
	
	push [bp+8]
	push [bp+6]
	call delay
	
	in al, 61h			;close speaker
	and al, 11111100b
	out 61h, al
	
	pop ax
	pop bp
	ret 6
endp playsound

proc random
    push bp
    mov bp, sp
    push es
    push bx
    push di
    push cx
    mov ax, 40h
    mov es, ax

    mov bx,[rando_x]
    mov di,[rando_y]

    mov al,[byte es:6Ch]
    mov ah,[byte cs:bx]
    xor al,ah

    mov ah,[byte ss:di]
    xor ah,al

    add [rando_x],7
    sub [rando_y],3
    mov cx,[rando_x]
    shr cx, 3
    ror [rando_y],cl

    and ax,[bp+4]
    pop cx    
    pop di
    pop bx
    pop es
    pop bp
    ret 2
endp random

proc dispose
    mov ax, 4c00h
    int 21h
    ret
endp dispose

proc delay
    push bp
    mov bp,sp

    push ax
    push dx
    push cx

    mov cx, [bp+6]      ;HIGH WORD.
    mov dx, [bp+4]      ;LOW WORD.
    mov ah, 86h         ;WAIT.
    int 15h   
    
    pop cx   
    pop dx
    pop ax

    pop bp
    ret 4
endp delay

proc clamp
    push bp
    mov bp,sp
    push bx
    push ax

    mov bx,[bp+4]
    mov ax,[bx]

    cmp ax,[bp+6]
    jae check_next
        mov ax,[bp+6]
    jmp done_clamp
    check_next:
        cmp ax,[bp+8]
        jbe done_clamp
            mov ax,[bp+8]
    done_clamp:
    mov [bx],ax
    pop ax
    pop bx
    pop bp
    ret 6
endp clamp

macro print_text_coord x,y,text
local @@start,@@msg
    push ax
    push ds
    push cx
    push dx
    push bx
    jmp @@start
@@msg db text,'$'
    @@start:
        mov ax, cs
        mov ds, ax
        mov dl, x
        mov dh, y
        xor bh,bh
        mov ah,2
        int 10h

        mov dx, offset @@msg
        mov ah, 9
        int 21h
    pop bx
    pop dx
    pop cx
    pop ds
    pop ax
endm print_text_coord

proc print_bin
    push bp
    mov bp, sp

    push ax
    push cx

    mov ax,[bp+4]
    mov cx,16
    print_binary:
        shl ax, 1
        jnc print_z
            printchar '1'
        jmp end_print_bin
        print_z:
            printchar '0'
        end_print_bin:
    loop print_binary

    pop cx
    pop ax

    pop bp
    ret 2
endp print_bin