# Chapter 06. Applied WebAssembly: Legacy Code in the Browser

This chapter introduces usage of Emscripten (LLVM platform based) toolchain.

## "Hello, World!" using Emscripten

Using the Emscripten C compiler, we tell it to compile the C code and generate
some JavaScript scaffolding. After that we may run the resuling file in Node.js:

```shell
emcc hello.c -o hello.js
```