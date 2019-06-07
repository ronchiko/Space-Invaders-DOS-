IDEAL
MODEL small
STACK 1000h
DATASEG
;Version macros
;label __debug__     ;defines the program is in debug mode
label __release__  ;defines the program is in release mode

rounds dw 1

include "util.asm"
include "object.asm"

include "graphics.asm"
include "invader.asm"
include "bullet.asm"
DATASEG
;Key trackers
right db 0      ;tracker of right arrow
left db 0       ;tracker of left arrow
space db 0      ;tracker of spacebar
;Score
score dw 0      ;current score
cooldown dw 0   ;player cool down
invader_count db 40

invader_graphics dw offset invader4_g,offset invader2_g,offset invader3_g,offset invader_g

cooldown_jump equ 10h
;Objects
player game_object <offset player_g,offset player_pallete,160,180,1b>         ;player instance
invaders invader 40 dup(<>)                                                   ;invader instance list
bullets bullet 15 dup(<>)


CODESEG
proc next_round     ;clears the screen and prints a message saying what round you are on, also summons the new round
    inc [rounds]
    print_text_coord 15,10,"Round "
    push [rounds] 
    call printuint
    rept 5
    push 0
    push 0FFFFh
    call delay
    endm
    mov ax,13h
    int 10h
    call construct_invaders
    call clean_bullets
    call summon_wave
    ret
endp next_round
proc add_score  ;adds score to the player and decreases the invader count
    push bp
    mov bp,sp
    push ax
    mov ax,[bp+4]
    add [score],ax
    dec [invader_count]
    pop ax
    pop bp
    ret 2
endp add_score

proc end_game
    mov ax, 13h
    int 10h
	push 07560h
	push offset game_over_snd
	call playstring
    call clear_screen
    print_text_coord 15,10,"GAME OVER"
    print_text_coord 10,12,"press r to restart"
    print_text_coord 10,14,"press enter to exit"
    mov [over_flage],1
    push es
    mov ax, 40h
    mov es,ax

    mov [word es:1ah],1eh
    mov [word es:1ch],1eh
    pop es
    wait_for_input:
        mov ah,1h
        int 16h
        jz wait_for_input
        mov ah,0
        int 16h

        cmp al,0Dh
        jne is_r
        call dispose
        is_r:
        cmp al,'r'
        jne wait_for_input
        call new_game
    ret
endp end_game

proc infoscreen
    push bp
    mov bp,sp
    sub sp, 4
    call clear_screen
    mov ax,13h
    int 10h
    print_text_coord 0,3,"RULES"
    print_text_coord 0,5,"Controls:"
    print_text_coord 0,6,"left and right arrow keys to move"
    print_text_coord 0,7,"space to shoot"
    print_text_coord 0,10,"Invaders give 1 point."
    print_text_coord 0,11,"Glowing invaders give 5 points."
    print_text_coord 0,12,"dont let the invaders reach the bottom"
    print_text_coord 0,13,"of the screen."
    print_text_coord 0,14,"Survive for the longest time, and reach"
    print_text_coord 0,15,"highest scores."
    print_text_coord 0,17,"press enter to return to main menu"
    mov ax,[word bp+6]
    mov [word bp-2], ax
    mov ax,[word bp+4]
	mov [word bp-4], ax
    wait_for_inputs_i:
	
		dec [word bp-2]
		cmp [word bp-2], 0
		jne change_sound_i
			mov [word bp-2], 50
			inc [word bp-4]
			cmp [word bp-4], 7
			jb change_sound_i
			mov [word bp-4],0
		change_sound_i:
		push 0
		push 02684h
		mov di,[word bp-4]
		shl di, 1
		push [start_theme+di]
		call playsound
		
		mov ah, 1
		int 16h
		jz wait_for_inputs_i
		
        mov ah,0
        int 16h
        cmp al,0Dh
        jne wait_for_inputs_i
    mov ax, [word bp-4]
    mov bx, [word bp-2]
	add sp, 4
	pop bp
    ret 4
endp infoscreen

proc start_screen
	push bp
	mov bp,sp
    sub sp, 4
    redraw:
    call clear_screen
    mov ax,13h
    int 10h
    print_text_coord 12,9,"SPACE INVADERS"
    print_text_coord 7,11,"developed by ron horowitz"
    print_text_coord 10,14,"press enter to start"
    print_text_coord 10,15,"press i for info"
	mov [word bp-2], 50
	mov [word bp-4], 0
    wait_for_inputs:
	
		dec [word bp-2]
		cmp [word bp-2], 0
		jne change_sound
			mov [word bp-2], 50
			inc [word bp-4]
			cmp [word bp-4], 7
			jb change_sound
			mov [word bp-4],0
		change_sound:
		push 0
		push 02684h
		mov di,[word bp-4]
		shl di, 1
		push [start_theme+di]
		call playsound
		
		mov ah, 1
		int 16h
		jz wait_for_inputs
		
        mov ah,0
        int 16h
        cmp al, 'i'
        jne check_enter
        push [word bp-4]
        push [word bp-2]
        call infoscreen
        mov [word bp-4],ax
        mov [word bp-2],bx
        call clear_screen
        jmp redraw
        check_enter:
        cmp al,0Dh
        jne wait_for_inputs
        call new_game
	add sp, 4
	pop bp
    ret
endp start_screen

proc new_game
    mov ax,13h
    int 10h
    mov [over_flage],0
    mov [word rounds],1
    mov [word score],0
    call construct_invaders
    call clean_bullets
    call summon_wave
    ret
endp new_game

proc clear_screen
    ;routine to draw all invaders
    mov di, offset invaders
    mov cx,40
    draw_invcls:
        call [di] method invader:update pascal,di
        call [di] method game_object:drawshade pascal,di
        add di, size invader
        loop draw_invcls

    mov di, offset bullets
    mov cx, 15
    draw_bulletscls:
        call [di] method bullet:update pascal,di
        call [di] method game_object:drawshade pascal,di
        add di,size bullet
        loop draw_bulletscls
    ;routine to draw player
    call [player] method game_object:drawshade pascal,offset player
    call clean_bullets
    call construct_invaders
    ret
endp clear_screen

proc create_bullet 
    push bp
    mov bp,sp
    push cx
    push di
    push dx
    push ax
    
    mov ax,[bp+6]
    mov dx,[bp+4]
    mov di,offset bullets
    mov cx, 15
    get_blt_llp:
        cmp [byte di+9],1
        je bullet_busy
            mov [byte di+9],1
            call [di] method bullet:set pascal,di [bp+10] [bp+8] [bp+12]
            mov [byte di+10], al
            mov [di+2],dx
            jmp get_blt_brk
        bullet_busy:
        add di,size bullet
        loop get_blt_llp
    get_blt_brk:
    pop ax
    pop dx
    pop di
    pop cx
    pop bp
    ret 10
endp create_bullet
;resets all the bullets on the screen
proc clean_bullets
    mov di,offset bullets
    mov cx, 15
    clean_blt_llp:
        mov [word di],offset bullet_g
        mov [word di+12],offset invaders
        call [di] method game_object:destroy pascal,di
        add di,size bullet
        loop clean_blt_llp
    ret
endp clean_bullets
;resets all the bullets on the screen
proc construct_invaders
    mov di,offset invaders
    mov cx, 40
    clean_inv_llp:
        push 111111b
        call random
        mov [word di],offset invader_g
        call [di] method invader:randompal pascal,di
        mov [byte di+8],10b
        mov [byte di+9], 1
        mov [byte di+10], 10101010b
        mov [byte di+11], 11110000b
        mov [byte di+12], al
        mov [word di+13], offset add_score
        mov [word di+15], offset end_game
        add di,size invader
        loop clean_inv_llp
    mov [space],0
    mov [right],0
    mov [left],0
    ret
endp construct_invaders
;handles input
proc read_input
    push bp
    mov bp, sp

    push ax
    push bx
    push es
    mov ax,40h
    mov es,ax
    
	read_inx:
		
		in ax, 60h
		
        cmp al, 'M'     ;check if right arrow pressed
        je try_right
        cmp al, 0CDh    ;check if right arrow released
        je close_right  
       
        jmp check_lf   ;end procedure

        try_right:
            mov [right],1   ;turn on right flag
			mov [left], 0
            jmp check_lf
        close_right:
            mov [right],0   ;turn off right flag
            jmp check_lf
        check_lf:  
        
		cmp al, 'K'     ;check if left arrow pressed
        je try_left
        cmp al, 0CBh    ;check if left arrow released
        je close_left  
        jmp check_sp
		try_left:
            mov [left],1    ;turn on left flag
			mov [right],0
			jmp check_sp
        close_left:
            mov [left],0    ;turn off left flag
            jmp check_sp
		check_sp:
		
		cmp al, '9'     ;check if spacebar pressed
        je try_space
        cmp al, 0B9h    ;check if spacebar released
        je close_space
		jmp close_all
        close_space:
            mov [space],0   ;turn off space flag
            jmp end_read
		try_space:
            inc [space]     ;turn on space flag
            jmp end_read
		
        end_read:
			nop
        close_all:
		
    pop es
    pop bx
    pop ax
    
    pop bp
    ret 2
endp read_input
;Sets up the invaders in a default wave formation
proc summon_wave
    mov ax,[rando_x]
    xor [rando_y],ax
    push 11b
    call random

    mov [byte invader_count],40
    mov di,ax
    shl di,1
    mov si,0
    mov ax, 30  ;first x
    mov dx, 20  ;first y
    xor bx,bx   ;reset instance pointer
    mov cx,40
    summon:
        mov [word invaders+bx+4], ax    ;set instance x
        mov [word invaders+bx+6], dx    ;set instance y
        push ax
        mov ax,[word palletes+di]
        mov [word invaders+bx+2],ax
        mov ax,[word invader_graphics+si]
        mov [word invaders+bx],ax
        pop ax
        add ax, 27                      ;increment x
        cmp ax, 280                     ;warp x
        jbe next_instance               
            mov ax, 30                  ;reset x
            add di,2
            add si,2
            add dx, 20                  ;increment y
        next_instance:  
        push 0
        push 0F120h
        call delay
		push 0
		push 04000h
		push 1140h
		call playsound
        push di
        mov di,offset invaders
        add di,bx
        call [di] method game_object:draw pascal,di
        pop di
        add bx, size invader            ;increment instance pointer
        loop summon
    ret
endp summon_wave
start:
    mov ax, @data
    mov ds, ax
    
    ;Enter graphic mode
    mov ax, 13h
    int 10h
    
    call start_screen
;main game loop
game_loop:

    call read_input ;handle input
    ;controls

    ;check if right arrow was pressed
    cmp [right],1   
    jne check_left
    inc [word player+4] ;move right
    ;check if left arrow was pressed
    check_left:
    cmp [left],1   
    jne check_space
    dec [word player+4] ;move left
    ;check if space was pressed
    check_space:
    cmp [space],1   
    jne draw_instances
    cmp [cooldown],0
    jne draw_instances

    mov [cooldown], cooldown_jump
    push 10b        ;hit mask
    push [player.x] ;x
    push [player.y] ;y
    push -10        ;speed
    push offset bulletp_pallete
	call create_bullet
	
	push 0
	push 07653h
	push 4560
	call playsound

    draw_instances:
    push 300
    push 20
    push offset player.x
    call clamp
    
    ;routine to draw all invaders
    mov di, offset invaders
    mov cx,40
    draw_inv:
        call [di] method invader:update pascal,di
        call [di] method game_object:draw pascal,di
        add di, size invader
        loop draw_inv

    mov di, offset bullets
    mov cx, 15
    draw_bullets:
        call [di] method bullet:update pascal,di
        call [di] method game_object:draw pascal,di
        add di,size bullet
        loop draw_bullets
    ;routine to draw player
    call [player] method game_object:draw pascal,offset player
    ;Print ui
    print_text_coord 0,0,"Score: "
    push [word score]
    call printuint
    cmp [byte invader_count],0
    jne timers
    ;Next round transition
    call next_round
    
    timers:
    inc [direction_time]
    cmp [direction_time],11h
    jl skip_reset
    mov [direction_time],0

    inc [cycles]
    cmp [cycles], 11
    jb skip_reset
    mov [cycles],0
    skip_reset:
    
    cmp [cooldown],0
    je skip_cooldown_timer
    dec [cooldown] 
    skip_cooldown_timer:

    jmp game_loop
exit:
	mov ax, 0
	int 10h
    call dispose
end start