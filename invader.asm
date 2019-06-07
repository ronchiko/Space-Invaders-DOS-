ifndef __game_object__
include "object.asm"
endif
ifndef __util__def
include "util.asm"
endif
DATASEG
over_flage db 0
direction_time dw 0
cycles dw 0
struc invader global game_object method {
        update:word = inv_up
        randompal:word = pal
        givescore:word = inv_givscr
    }
    horizontal db 10110110b ;motion cycle
    direction db  0b        ;direction cycle
    unique_ db 0            ;is the invader unique (extra points)
    death_event dw NOTHING  ;event to be executed on death (function pointer)
    on_goal dw NOTHING      ;event to be executed when the invader reaches his goal
ends invader

palletes dw offset invader_pallete,offset invader2_pallete,offset invader3_pallete,offset invader4_pallete,offset invader5_pallete
         dw offset invader6_pallete,offset invader7_pallete
CODESEG
proc inv_givscr pascal far
arg @@instance:word
uses di,bx
    mov di,[@@instance]
    cmp [byte di+12],0
    jne normal_score
        push 5
        call [word di+13]
    jmp finish_add
    normal_score:
        push 1
        call [word di+13]
    finish_add:
    ret
endp inv_givscr
proc pal pascal far
arg inst:word
uses bx,ax,di
    mov bx,[inst]
    
    pick_ran:
        push 1111b
        call random
        cmp ax, 7
        jae pick_ran
    shl ax,1
    mov di,ax
    mov ax,[palletes+di]
    mov [bx+2],ax
    ret
endp pal
;update invader
proc inv_up pascal far
arg inst:word
uses di,bx,ax,cx
    mov di,[inst]
    ;If invaders is unique make it go sesure mode
    cmp [byte di+12],0
    jne check_time
    call [di] method invader:randompal pascal,di

    check_time:
    ;check if time to move
    mov ax, 11h
    sub ax,[rounds]
    cmp ax, 1
    jge dir_time
    mov ax,1
    dir_time:
    cmp [direction_time], ax
    je execute_update
    ret
     
    execute_update:

    cmp [cycles],10
    jne skip_switch

    rol [byte di+10],1
    rol [byte di+11],2
    
    jne skip_switch

    skip_switch:

    mov cl,[byte di+10]
    shr cl,1
    jc mv_vertical
        mov ch, [byte di+11]
        shr ch,1 
        jc mv_left
            inc [word di+4]
            jmp end_proc2
        mv_left:
            dec [word di+4]
            jmp end_proc2
    mv_vertical:
        inc [word di+6]
    end_proc2:
    
    cmp [byte di+9], 0
    je not_in_goal_yet
    cmp [word di+6],180
    jb not_in_goal_yet

    cmp [over_flage],0
    jne not_in_goal_yet
    
    mov [over_flage],1
    call [word di+15]

    not_in_goal_yet:
    ret
endp inv_up