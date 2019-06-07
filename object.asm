ifndef __util__def
include "util.asm"
endif
DATASEG
label __game_object__
GAME_OBJECT_SIZE equ size game_object
struc game_object global method {
        draw:word = draw_object
        drawshade:word = draw_shade
        move:word = move_object
        set_position:word = set_object
        destroy:word = destory_obj
        restore:word = restore_obj
    }
    sprite dw ?
    pallete dw ?
    x dw ?
    y dw ?
    omask db 0
    exsits db 1
ends game_object

CODESEG
;draw a black 8x8 box on the object
proc draw_shade pascal far
arg instance:word
uses di,bx
    mov di,[instance]
    mov bx,[di+2]
    mov [word di+2],offset hide_p
    call [di] method game_object:draw pascal,di
    mov [di+2],bx
    ret
endp draw_shade
;restoress the game object
proc restore_obj pascal far
arg instance:word
uses bx
    mov bx,[instance]
    mov [byte bx+9],1
    ret
endp restore_obj
;destroys the game object
proc destory_obj pascal far
arg instance:word
uses bx
    mov bx,[instance]
    mov [byte bx+9],0
    ret
endp destory_obj
;moves an objects postion
proc move_object pascal far
arg @@object:word,\
    @@xmove:word,\
    @@ymove:word
uses ax,bx
    mov bx, [@@object]
    mov ax, [@@xmove]
    add [bx+4],ax
    mov ax, [@@ymove]
    add [bx+6],ax
    ret
endp move_object
;Sets an object posiotn
proc set_object pascal far
arg @@object:word,\
    @@xmove:word,\
    @@ymove:word
uses ax,bx
    mov bx, [@@object]
    mov ax, [@@xmove]
    mov [bx+4],ax
    mov ax, [@@ymove]
    mov [bx+6],ax
    ret
endp set_object
;draw the object, needs refrence
proc draw_object pascal far
arg @@object:word
uses bx,ax,cx,si,dx,di
    ;get the address of the object
    mov bx,[@@object]
    cmp [byte bx+9],0
    jne begin_draw_routine
        ret
    begin_draw_routine:
    ;Move dx sprite data
    mov si,[bx]
    
    ;Draw offsets
    mov cx, [bx+4]
    mov dx,[bx+6]
    ;dec dx
    add cx,9
    offs_t:                     ;draw top offset
        draw_pixel <cx>,<dx>,0
        dec cx
        cmp cx,[bx+4]
        jne offs_t
    
    mov dx, [bx+6]
    mov cx, [bx+4]
    add dx,8
    offs_r:                     ;draw right offset
        draw_pixel <cx>,<dx>,0
        dec dx
        cmp dx,[bx+6]
        jne offs_r
    mov dx, [bx+6]
    mov cx, [bx+4]
    add cx,9
    add dx,8
    offs_l:                     ;draw left offset
        draw_pixel <cx>,<dx>,0
        dec dx
        cmp dx,[bx+6]
        jne offs_l
    mov dx, [bx+6]
    mov cx, [bx+4]
    add cx,9
    add dx,9
    offs_b:                     ;draw bottom offset
        draw_pixel <cx>,<dx>,0
        dec cx
        cmp cx,[bx+4]
        jne offs_b
    ;Draw Sprite
    mov dx, 8
    print_y:
        push dx

        push bx
        mov bx, dx
        dec bx
        shl bx,1
        mov ax, [bx+si]  
        pop bx 

        mov cx, 8     
        print_x:
            xor di,di
            shr ax, 1
            jnc shift_di
                or di, 1b
            shift_di:
            shr ax, 1
            jnc shift_di2
                or di, 10b
            shift_di2:
            ;print
            push bx
            push ax
            push cx
            push dx
                add cx,[bx+4]           ;draw the pixel
                add dx,[bx+6] 
                mov bx,[bx+2]
                mov al,[byte bx+di]     ;read color from sprite map
                cmp al, 0FFh            ;check if the pixel is transparent
                je transparent_pixel                  
                mov bh, 00h
                mov ah,0ch
                int 10h
                transparent_pixel:
            pop dx
            pop cx
            pop ax
            pop bx
        loop print_x
    pop dx
    dec dx
    cmp dx, 0
    jne print_y

    ret
endp draw_object
