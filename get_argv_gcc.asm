; Name:     get_argv_gcc.asm
; Assemble: nasm -felf32 get_argv_gcc.asm
; Link:     gcc -m32 -oget_argv_gcc get_argv_gcc.o
; Run:      ./get_argv_gcc arg1 arg2 arg3

SECTION  .data
    argcstr     db `argc = %d\n\0`      ; backquotes for C-escapes
    argvstr     db `argv[%u] = %s\n\0`

SECTION .text
global  main
extern printf
main:

    push ebp                    ; Prolog
    mov ebp, esp
    push ebx                    ; Callee saved registers
    push esi

    mov eax, [ebp + 8]          ; argc
    push eax
    push argcstr
    call printf                 ; Call libc
    add esp, (2*4)              ; Adjust stack by 2 arguments

    mov esi, [ebp + 12]         ; **argv
    mov ebx, 0                  ; Index of argv
    .J1:
    mov eax, [esi + ebx * 4]    ; *argv[ebx]
    test eax, eax               ; Null pointer?
    je .J2                      ; Yes -> end of loop
    push eax                    ; Pointer to string
    push ebx                    ; Integer
    push argvstr                ; Pointer to format string
    call printf                 ; Call libc
    add esp, (3*4)              ; Adjust stack by 3 arguments
    inc ebx
    jmp .J1                     ; Loop
    .J2:

    xor eax, eax                ; Returncode = return(0)
    pop esi                     ; Epilog
    pop ebx
    leave
    ret