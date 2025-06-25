section .text
    global _start

_start:
    ; Set video mode to 320x200 256 colors (VGA mode 13h)
    mov ax, 0x13
    int 0x10

    ; Draw a square
    mov cx, 100      ; X position
    mov dx, 100      ; Y position
    mov bx, 20       ; Size of the square

draw_square:
    ; Calculate the pixel offset
    mov ax, dx       ; Y position
    shl ax, 8        ; Multiply by 256 (shift left by 8)
    add ax, dx       ; Add Y position (320 * Y)
    add ax, cx       ; Add X position
    mov di, ax       ; Store the pixel offset in DI

    ; Draw the square
    mov si, bx       ; Size of the square
    mov al, 0x0F     ; Color (white)

    ; Draw the square
    .draw_row:
        mov [video_memory + di], al
        inc di
        dec si
        jnz .draw_row

    ; Move to the next row
    inc dx
    cmp dx, 200
    jl draw_square

    ; Wait for a key press
    mov ah, 0
    int 0x16

    ; Set video mode back to text mode
    mov ax, 0x03
    int 0x10

    ; Exit program
    mov ax, 0x4C00
    int 0x21

section .bss
video_memory resb 64000  ; 320x200 pixels, 1 byte per pixel
