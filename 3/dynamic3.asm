; linuxthor
;
; dynamic ELF 'loader executed function' example
; 
; we arrange for the loader to load our shared object at which point code 
; in the well known function _init is executed (see so.asm)
;
; assemble with:
; (build shared object per so.asm)
; nasm -f elf64 -o dynamic3.o dynamic3.asm
; ld -o dynamic3 dynamic3.o
;

BITS 64

global _start
_start:
    mov  rax, 1
    mov  rdi, 1
    mov  rsi, string
    mov  rdx, len
    syscall

    mov rax, 60
    mov rdi, 0
    syscall

section .data
    string db 'in the main program!',0x0d,0x0a,0
    len equ $ - string

section .interp
    zig db '/lib64/ld-linux-x86-64.so.2',0
    zag db './0.so',0

section .dynamic
    dq 5,  zag
    dq 1,  0
    dq 6,  0
    dq 0,  0
