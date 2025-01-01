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