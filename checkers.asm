; checkers.asm
section .text
    global _start

_start:
    ; Set video mode to 256-color 640x480
    mov ax, 0x13
    int 0x10

    ; Draw the checkerboard
    call draw_checkerboard

    ; Wait for a key press
    call wait_for_key

    ; Return to text mode
    mov ax, 0x03
    int 0x10

    ; Exit program
    mov ax, 0x4C00
    int 0x21

draw_checkerboard:
    ; Set up registers for drawing
    mov ecx, 8          ; Number of rows of squares
    mov edx, 8          ; Number of columns of squares
    mov ebx, 0          ; Row index
    mov esi, 0          ; Column index
    mov eax, 0x0C       ; Color for black squares
    mov edi, 0x04       ; Color for red squares

    ; Loop through rows
draw_row:
    push ebx            ; Save row index
    push esi            ; Save column index

    ; Loop through columns
    mov esi, 0          ; Reset column index
draw_column:
    ; Calculate the color based on the position
    xor ebx, ebx       ; Clear ebx for color calculation
    add ebx, ebx       ; Double the row index
    add ebx, esi       ; Add column index
    and ebx, 1         ; Check if the sum is even or odd

    ; Select color
    cmp ebx, 0
    je draw_black
    mov bh, edi        ; Use red color
    jmp draw_square

draw_black:
    mov bh, eax        ; Use black color

draw_square:
    ; Draw the square at (column * 80 + row) * 8
    mov di, ebx        ; Use di to hold the color
    mov ebx, esi       ; Column index
    shl ebx, 3         ; Multiply by 8 (width of each square)
    add ebx, ebx       ; Multiply by 2 (for 16-bit color)
    mov edi, ebx       ; Store column offset in edi

    mov ebx, ebx       ; Row index
    shl ebx, 3         ; Multiply by 8 (height of each square)
    add edi, ebx       ; Add row offset

    ; Set the pixel color in VGA memory
    mov [0xA0000 + edi], di

    inc esi            ; Move to the next column
    cmp esi, edx       ; Check if we reached the end of the row
    jl draw_column      ; If not, continue drawing

    pop esi            ; Restore column index
    pop ebx            ; Restore row index
    inc ebx            ; Move to the next row
    cmp ebx, ecx       ; Check if we reached the end of the rows
    jl draw_row        ; If not, continue drawing

    ret

wait_for_key:
    ; Wait for a key press
    mov ah, 0x00
    int 0x16
    ret
