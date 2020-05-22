; linuxthor
;
; simple 'fake' dynamic ELF example
;
; adding a crafted .dynamic section means we arrange for the loader 
; to load something for us and then pass control..
;
; ./dynamic0: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), 
;   dynamically linked, interpreter /lib/x86_64-linux-gnu/ld-2.27.so
;
; assemble with:
; nasm -f elf64 -o dynamic0.o dynamic0.asm
; ld -o dynamic0 dynamic0.o

BITS 64

global _start
_start:
    mov  rax, 1            ; sys_write
    mov  rdi, 1
    mov  rsi, string
    mov  rdx, len
    syscall

    mov rax, 60            ; sys_exit
    mov rdi, 0
    syscall

section .data
    string db "don't panic - I'm dynamic!",0x0d,0x0a,0
    len equ $ - string

section .interp
    zig db '/lib/x86_64-linux-gnu/ld-2.27.so',0
    zag db 'libc.so.6',0 

section .dynamic
    dq 5,  zag              ; STRTAB
    dq 1,  0                ; NEEDED (libc.so.6)
    dq 6,  0                ; SYMTAB
    dq 0,  0                ; NULL (ends section)
