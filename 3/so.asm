; linuxthor
; 
; shared object with _init function 
;
; assemble with:
; nasm -f elf64 so.asm -o so.o
; gcc -shared so.o -o 0.so

BITS 64

global _init:function

_init:
    mov rax, 1
    mov rdi, 1
    mov rsi, string
    mov rdx, len
    syscall

    ret

section .data
    string db 'in the loader',0x0a,0x0d,0
    len equ $ - string

