; checkers.asm
[BITS 16]
[ORG 0x100]              ; .COM file entry point

section .text

start:
    ; Set video mode to 13h (320x200, 256-color)
    mov ax, 0x0013
    int 0x10

    call draw_checkerboard

    ; Wait for key press
    mov ah, 0x00
    int 0x16

    ; Return to text mode (03h)
    mov ax, 0x0003
    int 0x10

    ; Exit to DOS
    mov ax, 0x4C00
    int 0x21

; ------------------------------
; Draw checkerboard (8x8 squares)
; ------------------------------
draw_checkerboard:
    mov si, 0           ; Row index (0–7)

.next_row:
    mov di, 0           ; Column index (0–7)

.next_col:
    mov ax, si         ; Move row index to AX
    add ax, di         ; Add column index
    and al, 1          ; Use only the lowest bit to alternate color
    jz .color_black
.color_black:
    mov bl, 0x0C        ; black
.color_set:

    ; Compute pixel (x, y) start for current square
    ; Each square is 40x25 pixels (320/8 x 200/8)
    mov ax, di
    mov cx, 40
    mul cx              ; ax = col * 40
    mov dx, ax          ; dx = x

    mov ax, si
    mov cx, 25
    mul cx              ; ax = row * 25
    mov cx, ax          ; cx = y

    ; Draw 40x25 square at (dx, cx) with color bl
    push si
    push di
    call draw_square
    pop di
    pop si

    inc di
    cmp di, 8
    jl .next_col

    inc si
    cmp si, 8
    jl .next_row

    ret

; ----------------------------------------
; Draw 40x25 filled square at (x=dx, y=cx)
; Inputs:
;   dx = x position
;   cx = y position
;   bl = color
; ----------------------------------------
draw_square:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov si, cx          ; si = y start
    mov cx, 25          ; 25 rows

.row_loop:
    mov di, dx          ; di = x start
    mov bx, 40          ; 40 columns

.col_loop:
    ; Set pixel at (di, si) with color bl
    mov ah, 0x0C
    mov al, bl
    mov cx, di
    mov dx, si
    mov bh, 0x00        ; page 0
    int 0x10

    inc di
    dec bx
    jnz .col_loop

    inc si
    dec cx
    jnz .row_loop

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
