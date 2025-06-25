BITS 16

section .data
    paddle_color db 0x0F      ; White
    ball_color   db 0x0C      ; Red

section .bss
    paddle1_y resb 1          ; Paddle 1 Y position
    paddle2_y resb 1          ; Paddle 2 Y position
    ball_x     resb 1         ; Ball X position
    ball_y     resb 1         ; Ball Y position
    ball_dx    resb 1         ; Ball X direction
    ball_dy    resb 1         ; Ball Y direction

section .text
    global _start

_start:
    ; Set video mode 13h (320x200, 256 colors)
    mov ax, 0x13
    int 0x10

    ; Initialize game state
    mov byte [paddle1_y], 80
    mov byte [paddle2_y], 80
    mov byte [ball_x], 160
    mov byte [ball_y], 100
    mov byte [ball_dx], 1
    mov byte [ball_dy], 1

game_loop:
    call draw_frame
    call update_ball
    call handle_input
    jmp game_loop

; -------------------------------------
draw_frame:
    ; Clear screen
    mov ax, 0xA000
    mov es, ax
    xor di, di
    mov cx, 320*200
    xor al, al
    rep stosb

    ; Draw Paddle 1 (left)
    movzx ax, byte [paddle1_y]
    mov bx, 320
    mul bx
    mov di, ax
    mov cx, 10
.draw_paddle1:
    mov al, [paddle_color]
    mov [es:di], al
    add di, 320
    loop .draw_paddle1

    ; Draw Paddle 2 (right)
    movzx ax, byte [paddle2_y]
    mov bx, 320
    mul bx
    add ax, 310              ; right-side X offset
    mov di, ax
    mov cx, 10
.draw_paddle2:
    mov al, [paddle_color]
    mov [es:di], al
    add di, 320
    loop .draw_paddle2

    ; Draw Ball
    movzx ax, byte [ball_y]
    mov bx, 320
    mul bx
    mov bx, ax
    movzx ax, byte [ball_x]
    add bx, ax
    mov di, bx
    mov al, [ball_color]
    mov [es:di], al

    ret

; -------------------------------------
update_ball:
    ; Update ball X
    mov al, [ball_x]
    cbw
    mov bl, [ball_dx]
    add al, bl
    mov [ball_x], al

    ; Update ball Y
    mov al, [ball_y]
    cbw
    mov bl, [ball_dy]
    add al, bl
    mov [ball_y], al

    ; Check collision with top and bottom walls
    cmp al, 0
    jl .bounce_y
    cmp al, 199
    jg .bounce_y
    jmp .check_paddles

.bounce_y:
    mov al, [ball_dy]
    neg al
    mov [ball_dy], al

.check_paddles:
    mov al, [ball_x]
    cmp al, 10             ; Left paddle X
    je .hit_paddle1
    cmp al, 309            ; Right paddle X
    je .hit_paddle2
    ret

.hit_paddle1:
    mov al, [ball_y]
    mov bl, [paddle1_y]
    cmp al, bl
    jb .end_update
    add bl, 10
    cmp al, bl
    ja .end_update
    mov byte [ball_dx], 1
    ret

.hit_paddle2:
    mov al, [ball_y]
    mov bl, [paddle2_y]
    cmp al, bl
    jb .end_update
    add bl, 10
    cmp al, bl
    ja .end_update
    mov byte [ball_dx], -1
    ret

.end_update:
    ret

; -------------------------------------
handle_input:
    ; Placeholder - no controls yet
    ret
