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

This chapter equally introduces working with Strings. Check the contents of [strings.wasm](strings.wasm) to see
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

## The header in front of the strings

The first segment (`size=4`) is not text. It is a hand-written index that says where
the two strings in the second segment begin and how long each one is:

| offset | byte | decimal | meaning |
|--------|------|---------|---------|
| 0 | `\04` | 4  | address where string #1 starts |
| 1 | `\27` | 39 | length of string #1 in bytes |
| 2 | `\2b` | 43 | address where string #2 starts |
| 3 | `\1b` | 27 | length of string #2 in bytes |

The arithmetic checks out: string #1 is 13 Japanese characters at 3 UTF-8 bytes each =
39 bytes, so string #2 begins at 4 + 39 = 43. The second segment is 39 + 27 = 66
bytes, which is why `wasm-objdump` reports `size=66`.

[strings.html](strings.html) reads those four bytes back with `DataView.getUint8()`
and slices memory with `new Uint8Array(mem.buffer, start, length)`. Note that the
third argument is a *length*, not an end offset, despite the variable being called
`end`.

### Why the fields are one byte wide, and why that is a trap

Each of those four numbers occupies exactly **one byte**, and a byte holds values
`0`-`255`. So this header can only describe strings that start at an address at or
below 255 (the `start` fields) and that are at most 255 bytes long (the `length`
fields).

That is a much tighter budget than the memory itself provides. This module reserves
`1` page, i.e. 65,536 bytes, and a full address in that space needs 16 bits, not 8.
The header is therefore able to point at the first 256 bytes of a 65,536-byte
memory and no further. The example only works because everything happens to sit at
addresses 4 through 69.

Concretely, if the Japanese string grew from 39 to 300 bytes:

- `300 = 0x012C` needs two bytes instead of one, so the length field no longer fits;
- the 4-byte header would become a 5-byte header, shifting every address after it;
- `strings.html` hardcodes offsets `0`, `1`, `2` and `3`, so it would read the
  wrong fields and decode mojibake instead of reporting an error;
- `new Uint8Array(mem.buffer, start, length)` can even throw a `RangeError` once
  the mangled numbers point past the end of the buffer.

Nothing in WebAssembly enforces this layout. Memory is just bytes, and the
agreement between the module and the JavaScript is held together by arithmetic
that both sides happen to agree on. Widen the fields and the agreement breaks
silently.

The same reasoning explains why references in Java or Ruby look long rather than
like a single digit: an object reference has to be able to name *any* address in a
large heap, so it is given enough bits to reach all of it. Here the fields were
given far fewer bits than the address space actually requires.

A sturdier layout uses fixed-width fields that can address the whole page, for
example four little-endian `u16`s:

```wat
(data (i32.const 0x0) "\04\00\27\00\2b\00\1b\00")
```

```js
var start = dv.getUint16(0, true);  // little-endian
var length = dv.getUint16(2, true); // up to 65,535
```

Better still, store the offsets as `i32` (4 bytes) and read them with
`getUint32(offset, true)`, matching the width the module file format itself uses
for its `(data (i32.const ...))` addresses. Alternatively, export functions that
return the offsets, so the module owns its own layout and the JavaScript never has
to know the numbers.

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
