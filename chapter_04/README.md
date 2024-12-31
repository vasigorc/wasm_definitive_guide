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

This chapter equally introduces working with Strings. Check the contents of [strings.wasm](strings.wasm) to ee
how it is layed out:

```shell
wasm-objdump -x strings.wasm

strings.wasm:	file format wasm 0x1

Section Details:

Memory[1]:
 - memory[0] pages: initial=1
Export[1]:
 - memory[0] -> "memory"
Data[2]:
 - segment[0] memory=0 size=4 - init i32=0
  - 0000000: 0427 2b1b                                .'+.
 - segment[1] memory=0 size=66 - init i32=4
  - 0000004: e7a7 81e3 81af e6a8 aae6 b59c e381 abe4  ................
  - 0000014: bd8f e382 93e3 81a7 e381 84e3 81be e381  ................
  - 0000024: 97e3 819f e380 8249 2075 7365 6420 746f  .......I used to
  - 0000034: 206c 6976 6520 696e 2059 6f6b 6f68 616d   live in Yokoham
  - 0000044: 612e                                     a.
```

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
