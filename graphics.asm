IDEAL
MODEL small
STACK 100h
DATASEG



;color palletes
hide_p db 0h,0h,0h,0h
invader_pallete db 0h,0h, 2Ch, 2Ah
invader2_pallete db 0h, 0h, 23h, 22h
invader3_pallete db 0h, 0h, 3Eh, 40h
invader4_pallete db 0h, 0h, 32h, 2Fh
invader5_pallete db 0h, 0h, 35h, 36h
invader6_pallete db 0h, 0h, 0Eh, 41h
invader7_pallete db 0h, 0h, 0Fh, 1Dh
player_pallete db 0,0fh,2Eh,30h
bullete_pallete db 0h, 0Fh, 28h, 2Bh
bulletp_pallete db 0h, 0Fh, 36h, 33h

;graphics for invaders
invader_g  dw 1001010101010110b
dw 0110101010101001b
dw 1000101010100010b
dw 1000101010100010b
dw 1110101010101011b
dw 0111111111111101b
dw 1101110101110111b
dw 0101010101010101b

invader2_g dw 0000101010100000b
dw 0010101010101000b
dw 1010001010001010b
dw 1110001010001011b
dw 0011101010101100b
dw 0000111111110000b
dw 0011000000001100b
dw 1100000000000011b

invader3_g dw 0011100000101100b
 dw 0000111010110000b
 dw 0011101010101100b
 dw 1000101010100010b
 dw 1100101010100011b
 dw 0011101010101100b
 dw 0000111010110000b
 dw 0011001111001100b

invader4_g dw 0000111010110000b
dw 0011101010101100b
dw 1000101010100010b
dw 1000001010000010b
dw 1110101010101011b
dw 0011101010101100b
dw 1100100000100011b
dw 1100110000110011b
 
cleaner_g dw 0000000000000000b
dw 0000000000000000b
dw 0000000000000000b
dw 0000000000000000b
dw 0000000000000000b
dw 0000000000000000b
dw 0000000000000000b
dw 0000000000000000b

;player graphic
player_g dw 0000001010000000b
dw 0000001010000000b
dw 0000001010000000b
dw 0000111010110000b
dw 0011101010101100b
dw 1010101010101010b
dw 1110101010101011b
dw 0011111111111100b

;graphic for bullet
bullet_g dw 0000000000000000b
 dw 0000001010000000b
 dw 0000101111100000b
 dw 0000101111100000b
 dw 0000101111100000b
 dw 0000101111100000b
 dw 0000001010000000b
 dw 0000000000000000b
 
;Audios
enter_node dw 9121h,8609h,8126h,7670h,7239h,6833h,6449h,0

start_theme dw 4304h,3834h,3224h,2873h,2559h,2873h,3834h,4304h

game_over_snd dw 4 dup(9121h,7670h,3224h,4304h)