BITS 16

section .data
    paddle_color db 0x0F      ; White
    ball_color   db 0x0C      ; Red
    msg_game_over db "Game Over!$"

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
    call delay
    jmp game_loop

delay:
    mov cx, 0FFFFh
.wait:
    loop .wait
    ret

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
    add al, [ball_dx]
    mov [ball_x], al

    ; Update ball Y
    mov al, [ball_y]
    add al, [ball_dy]
    mov [ball_y], al

    ; Check collision with top and bottom walls
    cmp byte [ball_y], 0
    jb .bounce_y         ; jump if below
    cmp byte [ball_y], 199
    ja .bounce_y         ; jump if above

    call .check_paddles
    ret

.game_over:
    ; Switch to text mode and print message
    mov ax, 0x0003
    int 0x10
    mov ah, 0x09
    mov dx, msg_game_over
    int 0x21
    hlt

.bounce_y:
    mov al, [ball_dy]
    neg al
    mov [ball_dy], al
    ret

.check_paddles:
    mov al, [ball_x]
    cmp al, 10
    je .hit_paddle1
    cmp al, 240  ; Check if ball_x is near the right edge
    jge .hit_paddle2

    ; Ball missed paddles — Game Over if out of bounds
    cmp al, 0
    jb .game_over
    cmp al, 255  ; Check if ball_x is out of bounds on the right
    ja .game_over
    ret

.hit_paddle1:
    mov al, [ball_y]          ; Ball Y position
    mov bl, [paddle1_y]       ; Paddle 1 Y position (top of paddle)
    cmp al, bl
    jb .end_update            ; Ball is above the paddle
    add bl, 10                ; Paddle height = 10 pixels
    cmp al, bl
    ja .end_update            ; Ball is below the paddle

    mov byte [ball_dx], 1     ; Bounce right
    ret     ; Bounce right

.hit_paddle2:
    mov al, [ball_y]          ; Ball Y position
    mov bl, [paddle2_y]       ; Paddle 2 Y position (top of paddle)
    cmp al, bl
    jb .end_update            ; Ball is above the paddle
    add bl, 10                ; Paddle height = 10 pixels
    cmp al, bl
    ja .end_update            ; Ball is below the paddle

    mov byte [ball_dx], 0xFF    ; Bounce left
    ret

.bounce_up:
    mov byte [ball_dy], -1
    jmp .set_dx

.bounce_down:
    mov byte [ball_dy], 1

.set_dx:
    mov byte [ball_dx], 1
    ret

.end_update:
    ret

; -------------------------------------
handle_input:
    mov ah, 0x01        ; Check for keypress
    int 0x16
    jz .no_key          ; If no key, skip

    mov ah, 0x00        ; Wait and read key
    int 0x16

    cmp al, 0x1E        ; 'A' - Paddle 1 Up
    je .paddle1_up
    cmp al, 0x1F        ; 'S' - Paddle 1 Down
    je .paddle1_down
    cmp al, 0x48        ; Up arrow - Paddle 2 Up
    je .paddle2_up
    cmp al, 0x50        ; Down arrow - Paddle 2 Down
    je .paddle2_down
    jmp .end_input

.paddle1_up:
    cmp byte [paddle1_y], 0
    je .end_input
    dec byte [paddle1_y]
    jmp .end_input

.paddle1_down:
    cmp byte [paddle1_y], 190
    jge .end_input
    inc byte [paddle1_y]
    jmp .end_input

.paddle2_up:
    cmp byte [paddle2_y], 0
    je .end_input
    dec byte [paddle2_y]
    jmp .end_input

.paddle2_down:
    cmp byte [paddle2_y], 190
    jge .end_input
    inc byte [paddle2_y]
    jmp .end_input

.no_key:
.end_input:
    ret
