; linuxthor
; 
; shared object loader example
;
; assemble with:
; nasm -f elf64 so.asm -o so.o
; gcc -shared so.o -o 0.so

BITS 64

global _init:function

_init:
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel $ + 26] 
    mov rdx, len
    syscall

    mov rax, 60
    mov rdi, 0
    syscall

    strg db 'in the loader!',0x0a,0x0d,0
    len equ $ - strg

