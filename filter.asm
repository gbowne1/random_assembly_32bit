section .data
    samples dd 10 dup(0.0)  ; Array to hold the last 10 samples
    index   dd 0             ; Current index for the circular buffer
    sum     dd 0.0           ; Sum of the samples
    count   dd 10            ; Number of samples to average
    result  dd 0.0           ; Filtered result
    new_sample dd 0.0        ; New sample to be processed (initialize as needed)

section .text
    global _start

_start:
    ; Load new_sample into FPU
    fld dword [new_sample]   ; Load new sample onto FPU stack

    ; Update the circular buffer
    mov eax, [index]
    fstp dword [samples + eax*4] ; Store the new sample from FPU stack

    ; Update sum
    fld dword [sum]          ; Load current sum onto FPU stack
    fadd st0, st1            ; Add new sample to sum
    fstp dword [sum]         ; Store updated sum

    ; Subtract the oldest sample from sum
    fld dword [samples + eax*4] ; Load the oldest sample
    fsub st1, st0            ; Subtract the oldest sample from sum
    fstp dword [sum]         ; Store updated sum

    ; Calculate the average
    fld dword [sum]          ; Load sum
    fld dword [count]        ; Load count
    fdiv                      ; Divide sum by count
    fstp dword [result]      ; Store the result

    ; Update index for circular buffer
    inc dword [index]
    cmp dword [index], 10
    jl .done
    mov dword [index], 0     ; Reset index if it reaches 10

.done:
    ; Exit program (assuming DOS)
    mov ax, 0x4C00
    int 0x21
