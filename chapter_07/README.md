# Chapter 07. WebAssembly Tables

> Tables are another feature of WebAssembly that allow it to be a modern software system with functional
> dependencies that will be satisfied by modules. They provide the equivalent capability of a dynamic
> shared library.

## Static Versus Dynamic Linking

First example simply demonstrates how dynamic linking is used in C language.

```shell
# check root README.md for instructions about Nix shell set-up
[nix-shell:~/repos/wasm_definitive_guide]$ cd chapter_07

# compiler will use dynamic linking in the compiled binary
[nix-shell:~/repos/wasm_definitive_guide/chapter_07]$ clang main.c library.c

[nix-shell:~/repos/wasm_definitive_guide/chapter_07]$ ls -halF
total 36K
drwxrwxr-x  2 vasilegorcinschi vasilegorcinschi 4.0K Feb  1 13:32 ./
drwxrwxr-x 11 vasilegorcinschi vasilegorcinschi 4.0K Feb  1 13:16 ../
-rw-rw-r--  1 vasilegorcinschi vasilegorcinschi  372 Feb  1 13:27 README.md
-rwxr-xr-x  1 vasilegorcinschi vasilegorcinschi  16K Feb  1 13:32 a.out*
-rw-rw-r--  1 vasilegorcinschi vasilegorcinschi   79 Feb  1 13:27 library.c
-rw-rw-r--  1 vasilegorcinschi vasilegorcinschi  141 Feb  1 13:28 main.c
```

> You can verify that we are using dynamic linking here with the `nm` command:

```shell
0000000000003db0 d _DYNAMIC
0000000000003fb0 d _GLOBAL_OFFSET_TABLE_
0000000000002000 R _IO_stdin_used
                 w _ITM_deregisterTMCloneTable
                 w _ITM_registerTMCloneTable
0000000000001170 t _ZL6printfPKcU17pass_object_size1z
0000000000001260 t _ZL6printfPKcU17pass_object_size1z
0000000000002144 r __FRAME_END__
0000000000002024 r __GNU_EH_FRAME_HDR
0000000000004010 D __TMC_END__
0000000000000390 r __abi_tag
0000000000004010 B __bss_start
                 w __cxa_finalize@GLIBC_2.2.5
0000000000004000 D __data_start
0000000000001100 t __do_global_dtors_aux
0000000000003da8 d __do_global_dtors_aux_fini_array_entry
0000000000004008 D __dso_handle
0000000000003da0 d __frame_dummy_init_array_entry
                 w __gmon_start__
                 U __libc_start_main@GLIBC_2.34
                 U __stack_chk_fail@GLIBC_2.4
                 U __vprintf_chk@GLIBC_2.3.4
0000000000004010 D _edata
0000000000004018 B _end
0000000000001338 T _fini
0000000000001000 T _init
0000000000001060 T _start
0000000000004010 b completed.0
0000000000004000 W data_start
0000000000001090 t deregister_tm_clones
0000000000001140 t frame_dummy
0000000000001150 T main
00000000000010c0 t register_tm_clones
0000000000001250 T sayHello
```

Thus we may notice that `sayHello` and `main` memory address associated to them, but not `printf`.
