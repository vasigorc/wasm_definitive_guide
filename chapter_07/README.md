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

On Linux we may use `objdump` to see which dynamic libraries are required for the execution of our
binary:

```shell
[nix-shell:~/repos/wasm_definitive_guide/chapter_07]$ objdump -x a.out | grep "libc.so.6" -C 3
         filesz 0x0000000000000260 memsz 0x0000000000000260 flags r--

Dynamic Section:
  NEEDED               libc.so.6
  RUNPATH              /nix/store/j3nkzgjxfii9p1q4xw1b4y0y70v55i6k-nix-shell/lib:/nix/store/nqb2ns2d1lahnd5ncwmn6k84qfd7vx2k-glibc-2.40-36/lib:/nix/store/4gk773fqcsv4fh2rfkhs9bgfih86fdq8-gcc-13.3.0-lib/lib:/nix/store/bmjqxvy53752b3xfvbab6s87xq06hxbs-gcc-13.3.0-libgcc/lib
  INIT                 0x0000000000001000
  FINI                 0x0000000000001338
--
  RELACOUNT            0x0000000000000003

Version References:
  required from libc.so.6:
    0x09691a75 0x00 05 GLIBC_2.2.5
    0x0d696914 0x00 04 GLIBC_2.4
    0x09691974 0x00 03 GLIBC_2.3.4
```

In this case, we may see that `lib.so.6` library si required by the binary.

Similar principle is applicable in the WebAssembly context. In order to load different modules (and thus reducing disk and network usage)
in WebAssembly we use `Table` instance.

## Creating Tables in Modules

A new Wat keyword, `table` is introduced. This defines a collection of function references. The host can only
invoke the behaviour through the `Table` innstance. The `funcref` type is one of two allowed types for
this structure, the other being `externalref` that allows references to host values.

When analyzing the generated `*.wasm` file we may see that `Table` section was added there as well:

```shell
vasilegorcinschi@bonobo15:~/repos/wasm_definitive_guide/chapter_07$ wasm-objdump -x math.wasm | grep -C 2 Table | xclip -sel clip
 - func[0] sig=0
 - func[1] sig=0
Table[1]:
 - table[0] type=funcref initial=2 max=2
Export[1]:
```
