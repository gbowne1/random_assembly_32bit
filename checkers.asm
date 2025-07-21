[BITS 16]
[ORG 0x100]              ; .COM file entry point

section .text

start:
    ; Set video mode to 13h (320x200, 256-color)
    mov ax, 0x0013
    int 0x10

    call draw_checkerboard
    call draw_pieces

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
    ; Determine color based on row and column
    mov ax, si         ; Move row index to AX
    add ax, di         ; Add column index
    and al, 1          ; Use only the lowest bit to alternate color
    jz .color_red
    mov bl, 0x00        ; Black
    jmp .color_set
.color_red:
    mov bl, 0x0C        ; Red
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

; ------------------------------
; Draw pieces on the board
; ------------------------------
draw_pieces:
    ; Draw red pieces at the top
    mov si, 0           ; Row index (0–3)
    mov di, 1           ; Column index (1, 3, 5, 7)

.draw_red_pieces:
    ; Compute pixel (x, y) start for current piece
    ; Each piece is a circle with a radius of 5 pixels
    mov ax, di
    mov cx, 40
    mul cx              ; ax = col * 40 + 20
    add ax, 20
    mov dx, ax          ; dx = x

    mov ax, si
    mov cx, 25
    mul cx              ; ax = row * 25 + 12
    add ax, 12
    mov cx, ax          ; cx = y

    ; Draw piece at (dx, cx) with color 0x0C (red)
    push si
    push di
    mov bl, 0x0C        ; Red
    call draw_piece
    pop di
    pop si

    ; Move to the next piece
    add di, 2
    cmp di, 8
    jl .draw_red_pieces

    ; Move to the next row
    inc si
    cmp si, 3
    jl .draw_red_pieces

    ; Draw black pieces at the bottom
    mov si, 5           ; Row index (5–7)
    mov di, 0           ; Column index (0, 2, 4, 6)

.draw_black_pieces:
    ; Compute pixel (x, y) start for current piece
    ; Each piece is a circle with a radius of 5 pixels
    mov ax, di
    mov cx, 40
    mul cx              ; ax = col * 40 + 20
    add ax, 20
    mov dx, ax          ; dx = x

    mov ax, si
    mov cx, 25
    mul cx              ; ax = row * 25 + 12
    add ax, 12
    mov cx, ax          ; cx = y

    ; Draw piece at (dx, cx) with color 0x00 (black)
    push si
    push di
    mov bl, 0x00        ; Black
    call draw_piece
    pop di
    pop si

    ; Move to the next piece
    add di, 2
    cmp di, 8
    jl .draw_black_pieces

    ; Move to the next row
    inc si
    cmp si, 8
    jl .draw_black_pieces

    ret

; ----------------------------------------
; Draw a piece (circle) at (x=dx, y=cx)
; Inputs:
;   dx = x position
;   cx = y position
;   bl = color
; ----------------------------------------
draw_piece:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; Draw circle with a radius of 5 pixels
    mov si, -5
    mov di, -5

.draw_circle:
    ; Calculate x and y coordinates
    mov ax, si
    imul si
    mov bx, di
    imul bx
    add ax, bx
    cmp ax, 25
    jg .skip_pixel

    ; Set pixel at (dx + si, cx + di) with color bl
    mov ah, 0x0C
    mov al, bl
    mov bh, 0x00        ; page 0
    add dx, si
    add cx, di
    int 0x10
    sub dx, si
    sub cx, di

.skip_pixel:
    inc si
    cmp si, 6
    jle .draw_circle_row
    mov si, -5
    inc di
    cmp di, 6
    jle .draw_circle

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
