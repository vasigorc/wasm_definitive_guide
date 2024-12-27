# Chapter 2. "Hello, World!" (Sort of)

`hello.wasm` is already there, but you could have generated it like so:

```shell
cd chapter_02/
wat2wasm hello.wat
```

You may run it using `wasm3` interpreter (written in C):

```shell
➜  wasm_definitive_guide git:(main) cd chapter_02 
➜  chapter_02 git:(main) wasm3 --repl hello.wasm 
wasm3> how_old 2024 1982
Result: 42
```