# Chapter 4. WebAssembly Memory

In this chapter we're explicitly introducing the memory module, as
highlighted in the following inspection:

```shell
wasm-objdump -x memory.wasm

memory.wasm:	file format wasm 0x1

Section Details:

Memory[1]:
 - memory[0] pages: initial=1 max=10
Export[1]:
 - memory[0] -> "memory"
Data[1]:
 - segment[0] memory=0 size=4 - init i32=0
  - 0000000: 0101 0000  
```

You may want to inspect [memory2.wat](memory2.wat) in the same way.

## Link common JS and CSS files

```shell
# supposing you are in chapter_03 folder already
ln -s ../common common
```

To preview [index.html](index.html) file, the instructed step is:

```shell
# assumes presence of python3 on your host system
python3 -m http.server 10003
```

To view another HTML file from this directory, simply append its name to `localhost:10003` in the browser.
