; linuxthor
;
; dynamic ELF loader 'preloader loader' example 
;
; an example of using a shared object as an interpreter that will re-execute the ELF file 
; under the control of the standard system linker
;
; in this way some actions can be taken before the main program executes
;
; assemble with:
; (build shared object per so.asm)
; nasm -f elf64 -o dynamic4.o dynamic4.asm
; ld -o dynamic4 dynamic4.o
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
    zig db './0.so',0
    zag db 'libc.so.6',0

section .dynamic
    dq 5,  zag
    dq 1,  0
    dq 6,  0
    dq 0,  0
