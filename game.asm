section .data
    welcome_msg db 'Welcome to the Adventure Game!', 0
    choice_msg db 'Choose your path: (1) Go left (2) Go right', 0
    left_msg db 'You went left and found a treasure!', 0
    right_msg db 'You went right and fell into a pit!', 0
    input db 0

section .text
    global _start

_start:
    ; Print welcome message
    mov eax, 4          ; sys_write
    mov ebx, 1          ; file descriptor (stdout)
    mov ecx, welcome_msg
    mov edx, 30         ; length of the message
    int 0x80

    ; Print choice message
    mov eax, 4
    mov ebx, 1
    mov ecx, choice_msg
    mov edx, 40
    int 0x80

    ; Read user input
    mov eax, 3          ; sys_read
    mov ebx, 0          ; file descriptor (stdin)
    mov ecx, input
    mov edx, 1          ; read 1 byte
    int 0x80

    ; Check user input
    cmp byte [input], '1'
    je go_left
    cmp byte [input], '2'
    je go_right

go_left:
    mov eax, 4
    mov ebx, 1
    mov ecx, left_msg
    mov edx, 30
    int 0x80
    jmp exit

go_right:
    mov eax, 4
    mov ebx, 1
    mov ecx, right_msg
    mov edx, 30
    int 0x80

exit:
    mov eax, 1          ; sys_exit
    xor ebx, ebx        ; return 0
    int 0x80
