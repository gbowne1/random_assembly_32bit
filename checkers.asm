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

; -------------------------------
; Draw checkerboard (8x8 squares)
; -------------------------------
draw_checkerboard:
    mov si, 0           ; Row index (0–7)

.next_row:
    mov di, 0           ; Column index (0–7)

.next_col:
    ; Determine color based on row and column
    mov ax, si         ; Move row index to AX
    add ax, di         ; Add column index
    and al, 1          ; Use only the lowest bit to alternate color
    jz .color_blue
    mov bl, 0x07       ; Greyish White thingy
    jmp .color_set
.color_blue:
    mov bl, 0x01       ; Blue
.color_set:

    ; Compute pixel (x, y) start for current square
    ; Each square is 40x25 pixels (320/8 x 200/8)
    mov ax, di
    mov cx, 40
    mul cx              ; ax = col * 40
    mov dx, ax          ; dx = x

    push dx
    mov ax, si
    mov cx, 25
    mul cx              ; ax = row * 25
    mov cx, ax          ; cx = y
    pop dx

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
    pusha
    mov byte [square_color], bl
    mov byte [square_width], 40
    mov byte [square_height], 25
    mov word [square_xpos], dx
    mov word [square_ypos], cx

    mov dx, word [square_ypos]
.row_loop:
    mov cx, word [square_xpos]
    mov bl, byte [square_width]
.col_loop:
    ; Set pixel at (di, si) with color bl
    mov ah, 0x0C
    mov al, byte [square_color]
    mov bh, 0                   ; page = 0
    int 0x10                    ; set pixel
    inc cx
    dec bl
    jnz .col_loop
    inc dx
    dec byte [square_height]
    jnz .row_loop
    popa
    ret

; ------------------------------
; Draw pieces on the board
; ------------------------------
draw_pieces:
    ; Draw red pieces at the top
    lea si, start_red_table

.draw_red_pieces:
    mov bl, byte [si]   ; Row index from table (0–3 etc..)
    inc si
    mov bh, byte [si]   ; Column index from table (1, 3, 5, 7 etc..)

    ; Compute pixel (x, y) start for current piece
    ; Each piece is a circle with a radius of 5 pixels
    movzx ax, bh
    mov cx, 40
    mul cx              ; ax = col * 40 + 20
    add ax, 20
    mov dx, ax          ; dx = x
    push dx
    movzx ax, bl
    mov cx, 25
    mul cx              ; ax = row * 25 + 12
    add ax, 12
    mov cx, ax          ; cx = y
    pop dx
    ; Draw piece at (dx, cx) with color 0x0C (red)
    push bx
    mov bl, 0x0C        ; Red
    call draw_piece
    pop bx
    ; Move to the next piece
    inc si
    mov al, byte [si]
    cmp al, 255
    jne .draw_red_pieces

    ; Draw black pieces at the bottom
    lea si, start_black_table

.draw_black_pieces:
    mov bl, byte [si]   ; Row index from table (5–7 etc..)
    inc si
    mov bh, byte [si]   ; Column index from table (0, 2, 4, 6 etc..)

    ; Compute pixel (x, y) start for current piece
    ; Each piece is a circle with a radius of 5 pixels
    movzx ax, bh
    mov cx, 40
    mul cx              ; ax = col * 40 + 20
    add ax, 20
    mov dx, ax          ; dx = x
    push dx
    movzx ax, bl
    mov cx, 25
    mul cx              ; ax = row * 25 + 12
    add ax, 12
    mov cx, ax          ; cx = y
    pop dx
    ; Draw piece at (dx, cx) with color 0x00 (black)
    push bx
    mov bl, 0x00        ; Black
    call draw_piece
    pop bx
    ; Move to the next piece
    inc si
    mov al, byte [si]
    cmp al, 255
    jne .draw_black_pieces
    ret

; ----------------------------
; Draw a piece at (x=dx, y=cx)
; Inputs:
;   dx = x position
;   cx = y position
;   bl = color
; ----------------------------
draw_piece:
    pusha
    mov byte [piece_width], 10
    mov byte [piece_height], 10
    mov ax, dx
    mov dx, cx
    mov cx, ax
    sub cx, 5
    sub dx, 5
    mov word [piece_x], cx
    mov word [piece_y], dx
    mov byte [piece_col], bl
    lea si, piece_graphic
.draw_check:
    lodsb
    cmp al,0
    jne .draw_checkpix
    jmp .no_draw_advance
 .draw_checkpix:
    mov ah,0xc
    mov al,byte [piece_col]
    mov bh,0
    int 0x10
.no_draw_advance:
    inc cx
    dec byte [piece_width]
    jnz .draw_check
    mov byte [piece_width], 10
    mov cx,word [piece_x]
    inc dx
    dec byte [piece_height]
    jnz .draw_check
    popa
    ret

    ; Some data
square_width:   db 0
square_height:  db 0
square_color:   db 0
square_xpos:    dw 0
square_ypos:    dw 0

start_red_table:    db 0,1,0,3,0,5,0,7,1,0,1,2,1,4,1,6,2,1,2,3,2,5,2,7,255
start_black_table:  db 5,0,5,2,5,4,5,6,6,1,6,3,6,5,6,7,7,0,7,2,7,4,7,6,255
piece_x:    dw 0
piece_y:    dw 0
piece_width:    db 0
piece_height:   db 0
piece_col:  db 0
piece_graphic:
    db 0,0,0,1,1,1,1,0,0,0
    db 0,0,1,1,1,1,1,1,0,0
    db 0,1,1,1,1,1,1,1,1,0
    db 1,1,1,1,1,1,1,1,1,1
    db 1,1,1,1,0,0,1,1,1,1
    db 1,1,1,1,0,0,1,1,1,1
    db 1,1,1,1,1,1,1,1,1,1
    db 0,1,1,1,1,1,1,1,1,0
    db 0,0,1,1,1,1,1,1,0,0
    db 0,0,0,1,1,1,1,0,0,0
