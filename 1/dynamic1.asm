; linuxthor
;
; dynamic ELF load-me-do with a weird twist
;
; we can ask the loader to load some ELF file for us (e.g /bin/bash -
; not just .so libraries) it will be placed in memory along with it's
; dependencies (e.g libc.so, libtinfo.so etc)
;
; we can also use some code in memory to do something in a ROP gadget
; way..
;
; assemble with:
; nasm -f elf64 -o dynamic1.o dynamic1.asm
; ld -o dynamic1 dynamic1.o
;

BITS 64

global _start
_start:
    push mungo          ; "works on my machine" guaranteed:
    add  rdx, 899       ; <_dl_fini+899>:       retq
    jmp  rdx

                        ; we shouldn't get here..
    mov  rax, 1         ; sys_write
    mov  rdi, 1
    mov  rsi, string
    mov  rdx, len
    syscall

    mov rax, 60         ; sys_exit
    mov rdi, 0
    syscall

mungo:                  ; we should end up here..
    mov rax, 60         ; sys_exit
    mov rdi, 2
    syscall

section .data
    string db 'yello world!',0x0d,0x0a,0
    len equ $ - string

; usefully the loader will place /bin/bash in memory and all
; the dependencies of that (e.g libc.so, libtinfo.so etc)
; before passing over to _start..

section .interp
    zig db '/lib/x86_64-linux-gnu/ld-2.27.so',0
    zag db '/bin/bash',0

section .dynamic
    dq 5,  zag
    dq 1,  0
    dq 6,  0
    dq 0,  0
