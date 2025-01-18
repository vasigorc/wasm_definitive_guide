# Chapter 5. Using C/C++ and WebAssembly

You may compile C code using `clang` like such:

```shell
clang howold.c
```

To generate an Assembly file using `clang` run

```shell
clang -S howold.c
# example of how it could look like (instructions differ per CPU architecture)
head -10 howold.s
	.file	"howold.c"
	.text
	.globl	howOld                          # -- Begin function howOld
	.p2align	4
	.type	howOld,@function
howOld:                                 # @howOld
	.cfi_startproc
# %bb.0:
	pushq	%rbp
```

## Compile C code to WebAssembly

[howold2.c](howold2.c) is an abridged version of the above program, that doesn't contain an entry point `main` function.

In order to be able to use it in WebAssembly, we have to compile it by targeting `wasm32` WebAssembly platform.

```shell
clang --target=wasm32 -nostdlib -Wl,--no-entry,--export-all howold2.c -o howold.wasm
```

## Mini web-app that uses C generated code

The generated [howold.wasm](howold.wasm) is embedded in [howold.html](howold.html) web page.

Run:

```shell
python3 -m http.server 10003
Serving HTTP on 0.0.0.0 port 10003 (http://0.0.0.0:10003/) ...
127.0.0.1 - - [01/Jan/2025 12:46:01] "GET /howold.html HTTP/1.1" 200 -
```

and navigate to `localhost:10003/howold.html` to see how JS dynamically uses native code produced by C:

![How old app](images/ch05_howold.png)

## Compile two C files with an entrypoint using `clang`

```shell
clang simplemain.c simple.c -o simplemain.out
# to analyze the generated binary file
nm -a simplemain.out
0000000000000000 a
0000000000000358 r __abi_tag
0000000000001180 T addArray
000000000000401c B __bss_start
000000000000401c b completed.0
0000000000000000 a crtbeginS.o
0000000000000000 a crtendS.o
                 w __cxa_finalize@GLIBC_2.2.5
0000000000004018 D __data_start
0000000000004018 W data_start
0000000000001090 t deregister_tm_clones
0000000000001100 t __do_global_dtors_aux
0000000000003dd0 d __do_global_dtors_aux_fini_array_entry
0000000000003dd8 D __dso_handle
0000000000003de0 d _DYNAMIC
000000000000401c D _edata
0000000000004020 B _end
00000000000011dc T _fini
0000000000001140 t frame_dummy
0000000000003dc8 d __frame_dummy_init_array_entry
0000000000002110 r __FRAME_END__
0000000000003fe8 d _GLOBAL_OFFSET_TABLE_
                 w __gmon_start__
0000000000002048 r __GNU_EH_FRAME_HDR
0000000000001000 T _init
0000000000002000 R _IO_stdin_used
                 w _ITM_deregisterTMCloneTable
                 w _ITM_registerTMCloneTable
                 U __libc_start_main@GLIBC_2.34
0000000000001150 T main
                 U memcpy@GLIBC_2.14
                 U printf@GLIBC_2.2.5
00000000000010c0 t register_tm_clones
0000000000000000 a Scrt1.o
0000000000000000 a simple.c
0000000000000000 a simplemain.c
0000000000001060 T _start
0000000000004020 D __TMC_END__
```

## Make a function return a newly constructed array in C

This example maybe found in file [simple5.c](simple.c):

```shell
clang simple5.c -o simple5.out
./simple5.out
a is 0x562b916022a0
The first value is 0
The second value is 1
The third value is 2
```

## A low level Helloworld with C/C++ and WASM

In this section the author of the book introduced a "Hello, world!" WASM example based on purely
C/C++ files and `clang` compiler. This is based on this [git repo](https://github.com/PetterS/clang-wasm)
and purposefully avoids using Escripten or WASI in order to demonstrate what is being done under
the hood. The expectation is to remove the complexity as chapters progress.

## A "Hello, World!" project in WebAssembly

Following the section on pp. 84-86. [helloworld](./helloworld) directory in this chapter's code directory
offers an implementation of a small program that highlights libraries and required supported code that is
needed to simply print "Hello, world!" to the JavaScript console. [nanolibc](./helloworld/nanolibc) includes
low-level code that provides some basic functionality, such as `printf()` that are normally
provided by the operating system. In the subsequent chapters, Brian Sletten (the author) covers how to
port existing software to WebAssembly with much less pain. With this project, he highlights
how this could be done by hand.
