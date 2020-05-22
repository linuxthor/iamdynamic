# iamdynamic

_"..don't panic.. it's dynamic.."_

Linux assembly language examples showing the minimum required to be recognised and loaded as a dynamic ELF file plus these "few weird tricks!" 

The things that distinguish a dynamic ELF file from a static one are the presence of:

1) an .interp section naming the loader/helper (e.g /lib64/ld-linux-x86-64.so.2) 
2) a .dynamic section which can contain various mandatory(_-ish_) fields and other optional fields   

[dynamic0](https://github.com/linuxthor/iamdynamic/blob/master/0/dynamic0.asm)

This example shows the very minimum required to be recognised as a dynamic ELF and to arrange for the loader to pass control to our code. 
```
./dynamic0: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib/x86_64-linux-gnu/ld-2.27.so, not stripped
```
 
[dynamic1](https://github.com/linuxthor/iamdynamic/blob/master/1/dynamic1.asm)

This example demonstrates that the loader will load some arbitrary ELF file into memory for us (e.g /bin/bash) and also it's dependencies. We can use code that we can locate in memory in a ROP-ish way. 
```
00400000-00602000 rwxp 00000000 fd:01 396646                             /home/j100/dynamics/1/dynamic1
7ffff729c000-7ffff7483000 r-xp 00000000 fd:01 5903028                    /lib/x86_64-linux-gnu/libc-2.27.so
7ffff7483000-7ffff7683000 ---p 001e7000 fd:01 5903028                    /lib/x86_64-linux-gnu/libc-2.27.so
7ffff7683000-7ffff7687000 r-xp 001e7000 fd:01 5903028                    /lib/x86_64-linux-gnu/libc-2.27.so
7ffff7687000-7ffff7689000 rwxp 001eb000 fd:01 5903028                    /lib/x86_64-linux-gnu/libc-2.27.so
7ffff7689000-7ffff768d000 rwxp 00000000 00:00 0
7ffff768d000-7ffff7690000 r-xp 00000000 fd:01 5903051                    /lib/x86_64-linux-gnu/libdl-2.27.so
7ffff7690000-7ffff788f000 ---p 00003000 fd:01 5903051                    /lib/x86_64-linux-gnu/libdl-2.27.so
7ffff788f000-7ffff7890000 r-xp 00002000 fd:01 5903051                    /lib/x86_64-linux-gnu/libdl-2.27.so
7ffff7890000-7ffff7891000 rwxp 00003000 fd:01 5903051                    /lib/x86_64-linux-gnu/libdl-2.27.so
7ffff7891000-7ffff78b6000 r-xp 00000000 fd:01 5903186                    /lib/x86_64-linux-gnu/libtinfo.so.5.9
7ffff78b6000-7ffff7ab6000 ---p 00025000 fd:01 5903186                    /lib/x86_64-linux-gnu/libtinfo.so.5.9
7ffff7ab6000-7ffff7aba000 r-xp 00025000 fd:01 5903186                    /lib/x86_64-linux-gnu/libtinfo.so.5.9
7ffff7aba000-7ffff7abb000 rwxp 00029000 fd:01 5903186                    /lib/x86_64-linux-gnu/libtinfo.so.5.9
7ffff7abb000-7ffff7bbf000 r-xp 00000000 fd:01 5243701                    /bin/bash
7ffff7bbf000-7ffff7dbe000 ---p 00104000 fd:01 5243701                    /bin/bash
7ffff7dbe000-7ffff7dc2000 r-xp 00103000 fd:01 5243701                    /bin/bash
7ffff7dc2000-7ffff7dcb000 rwxp 00107000 fd:01 5243701                    /bin/bash
7ffff7dcb000-7ffff7dd5000 rwxp 00000000 00:00 0
7ffff7dd5000-7ffff7dfc000 r-xp 00000000 fd:01 5903000                    /lib/x86_64-linux-gnu/ld-2.27.so
7ffff7fb6000-7ffff7fb8000 rwxp 00000000 00:00 0
7ffff7ff5000-7ffff7ff7000 rwxp 00000000 00:00 0
7ffff7ff7000-7ffff7ffa000 r--p 00000000 00:00 0                          [vvar]
7ffff7ffa000-7ffff7ffc000 r-xp 00000000 00:00 0                          [vdso]
7ffff7ffc000-7ffff7ffd000 r-xp 00027000 fd:01 5903000                    /lib/x86_64-linux-gnu/ld-2.27.so
7ffff7ffd000-7ffff7ffe000 rwxp 00028000 fd:01 5903000                    /lib/x86_64-linux-gnu/ld-2.27.so
7ffff7ffe000-7ffff7fff000 rwxp 00000000 00:00 0
7ffffffde000-7ffffffff000 rwxp 00000000 00:00 0                          [stack]
ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0                  [vsyscall]
```

[dynamic2](https://github.com/linuxthor/iamdynamic/blob/master/2/dynamic2.asm) 

This is where things get a bit more weird and interesting! The file specifies a shared object as it's loader that performs some actions and exits - therefore the program code observed in this file __never executes__. Any attempt to analyse the actions taken by this program (without also examining the loader) would be a waste of time!  
```
dynamic2: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter ./0.so, not stripped
```

[dynamic3](https://github.com/linuxthor/iamdynamic/blob/master/3/dynamic3.asm)

In this example we use the system loader and ask it to load our shared object - this has the side effect of automatically executing code in the init function of that library. This can serve as the basis for some anti-debug technique as the code is executed very early. 

e.g gdb:  
```
(gdb) b _start
Breakpoint 1 at 0x400150
(gdb) b _init
Function "_init" not defined.
Make breakpoint pending on future shared library load? (y or [n]) y
Breakpoint 2 (_init) pending.
(gdb) run
Starting program: /home/j100/dynamics/3/dynamic3 
warning: Probes-based dynamic linker interface failed.
Reverting to original interface.

in the loader <== HERE 

Breakpoint 1, 0x0000000000400150 in _start ()
```

[dynamic4](https://github.com/linuxthor/iamdynamic/blob/master/4/dynamic4.asm) 

This example specifies the included shared object as it's loader. After the shared object finishes it's work it executes the system loader as an ELF binary (which is valid on Linux) and asks it to execute the example file under the control of the system loader. As the loader is re-executing our file we don't need to know the entrypoint (which isn't always useful anyway depending on how things are loaded in memory etc..)

Editing the .interp section of an ELF binary to add a loader like the one in dynamic4 is a reasonable way to take control of execution before the normal entry point is reached..  

e.g we take a copy of /bin/echo and change the .interp section so that the loader is ./0.so and not /lib64/ld-linux-x86-64.so.2 and our library code will be executed - control is then given back to echo by executing /lib64/ld-linux-x86-64.so.2 asking to re-execute the binary which will, this time, ignore the library set in .interp and enter the program via it's usual entrypoint 
```
file ./echo
./echo: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, interpreter ./0.so, for GNU/Linux 3.2.0, BuildID[sha1]=057373f1356c861e0ec5b52c72804c86c6842cd5, stripped
bash$ ./echo I AM THE WALRUS
i am dynamic loader
I AM THE WALRUS
```
