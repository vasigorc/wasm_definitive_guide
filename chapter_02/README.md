# Chapter 2. "Hello, World!" (Sort of)

You may run it using `wasm3` interpreter (written in C):

```shell
➜  wasm_definitive_guide git:(main) cd chapter_02 
➜  chapter_02 git:(main) wasm3 --repl hello.wasm 
wasm3> how_old 2024 1982
Result: 42
```

 ## Link common JS and CSS files

```shell
# supposing you are in chapter_02 folder already
ln -s ../common common
```

To preview [index.html](index.html) file that runs [hello.wasm](hello.wasm) file the instructed step is:

```shell
# assumes presence of python3 on your host system
python3 -m http.server 10003
```