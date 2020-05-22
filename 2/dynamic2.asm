; linuxthor
;
; dynamic ELF "non executing" file example
; 
; the code in _start won't execute.. the loader ./0.so (see so.asm) 
; will perform some actions and terminate 
;
; ./dynamic2: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), 
;                 dynamically linked, interpreter ./0.so, not stripped
;
; assemble with:
; (n.b:- build the .so first per notes in so.asm) 
; nasm -f elf64 -o dynamic2.o dynamic2.asm
; ld -o dynamic2 dynamic2.o
 
BITS 64

global _start
_start:
    mov  rax, 1           ;  sys_write
    mov  rdi, 1
    mov  rsi, string
    mov  rdx, len
    syscall

    mov rax, 60           ;  sys_exit
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
