; linuxthor
;
; shared object ELF 'preloading' via dynamic interpreter
; 
; this shared object is loaded as the interpreter for some ELF file (as specified in 
; it's .dynamic section) where it performs an action before passing back control by:
;
; 1) resolving the full path to the ELF via /proc/self/exe
; 2) executing the linux dynamic linker passing the ELF path
;
; the code is quite messy as it uses rip relative addressing 
;
; (this is a complete hack / PoC but it works!)
;
; assemble with:
; nasm -f elf64 so.asm -o so.o
; gcc -shared so.o -o 0.so
;

global _init:function
_init:
    mov rax, 1                      ;  sys_write
    mov rdi, 1
    lea rsi, [rel $ + (msg - $)]
    mov rdx, len
    syscall

    mov rax, 89                     ;  sys_readlink
    lea rdi, [rel $ + (rdl - $)]
    lea rsi, [rsp + 64]
    mov rdx, 64
    syscall

    mov byte [(rsp + 64) + rax], 0
    lea rbx, [rsp + 64]

    mov rax, 59                     ;  sys_execve
    lea rdi, [rel $ + (cmd - $)]
    mov [rsp], rdi
    mov [rsp+8], rbx
    mov rsi, rsp
    mov rdx, 0
    syscall

    mov rax, 60                     ;  sys_exit
    mov rdi, 0
    syscall

    cmd db '/lib64/ld-linux-x86-64.so.2',0
    rdl db '/proc/self/exe',0
    msg db 'i am dynamic loader',0x0d,0x0a,0
    len equ $ - msg
