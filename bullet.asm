ifndef __game_object__
include "object.asm"
endif
DATASEG
struc bullet global game_object method{
        update:word = blt_update
        set:word = blt_set
    }
    speed db 3      ;the motion speed of the bullet updwards
    hitmask db 0b   ;what should it hit
    check_address dw 0
ends bullet
CODESEG
proc blt_set pascal far
arg instance:word,x:word,y:word,hmask:byte
uses bx,ax
    mov bx,[instance]

    mov ax,[x]
    mov [bx+4],ax

    mov ax,[y]
    mov [bx+6],ax

    mov [byte bx+9],1

    mov al, [hmask]
    mov [bx+11],al
    ret
endp blt_set
;behavoiur of the bullet
proc blt_update pascal far
arg instance:word
uses di,ax,cx,bx,si,dx
    mov di,[instance]

    cmp [byte di+9],0
    jne execute_blt_behavoiur
    jmp end_behavoiur
    execute_blt_behavoiur:
    ;move bullet
    mov al,[byte di+11]
    xor ah,ah
    sub [word di+6], ax
    ;world edges
    cmp [word di+6], -4
    jg check_collision
        mov [word di+2], offset hide_p
        call [di] method game_object:draw pascal,di
        mov [byte di+9],0
        ret
    check_collision:
    push bp
    mov bp,sp
    sub sp,4    ;create 2 new temporary variables

    mov cx,40       ;iteration count
    mov bx,[di+12]  ;array index
    check_instance:
        push cx
        cmp [byte bx+9],0
        je not_colliding
        
        ;Get self vertecies
        mov cx,[di+4]
        add cx, 8
        mov [bp-2],cx   ;self horizontal edge
        mov cx,[di+6]
        add cx,8
        mov [bp-4],cx   ;self vertical edge
        ;Get instance coordinates
        mov cx,[bx+4]
        mov dx,[bx+6]
        ;check if x out left?
        cmp [bp-2],cx 
        jb not_colliding
        ;check if y out top?
        cmp [bp-4],dx
        jb not_colliding
        ;move to instance edge cooridantes
        add dx,8
        add cx,8
        ;check if x out right?
        cmp [di+4],cx
        ja not_colliding
        ;check if y out bottom?
        cmp [di+6],dx
        ja not_colliding
        ;If this stage is reaches the objects are colliding
        call [bx] method invader:givescore pascal,bx
        call [bx] method game_object:drawshade pascal,bx		
        mov [byte bx+9],0 

        call [di] method game_object:drawshade pascal,di
        mov [byte di+9],0
		push 02650h
		push offset enter_node
		call playstring
        pop cx
        jmp break_k
        not_colliding:
        pop cx
        
        add bx,size invader
        loop check_instance
    break_k:
    add sp,4
    pop bp
    end_behavoiur:
    ret
endp blt_update