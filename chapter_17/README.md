# WebAssembly and Other Languages

## Zig

### How Old (Zig version)

The syntax for building a "freestanding" WebAssembly module in Zig has changed since
the time of the writing of the book. The new syntax looks like this:

```bash
cd chapter_17/howold
zig build-exe howOld.zig -target wasm32-freestanding -fno-entry -rdynamic
```

And then this will provide the following files in the targeted directory (`howold` in our case):

```bash
ls -lat
total 1056
drwxr-xr-x 2 vasilegorcinschi vasilegorcinschi   4096 Aug 11 22:50 .
-rwxr-xr-x 1 vasilegorcinschi vasilegorcinschi 693671 Aug 11 22:50 howOld.wasm
-rw-r--r-- 1 vasilegorcinschi vasilegorcinschi 372230 Aug 11 22:50 howOld.wasm.o
-rw-r--r-- 1 vasilegorcinschi vasilegorcinschi     69 Aug 11 22:41 howOld.zig
drwxr-xr-x 3 vasilegorcinschi vasilegorcinschi   4096 Aug 11 22:41 ..
```

Running the generated WebAssembly code with Node didn't change though:

```bash
node main.js
You are: 21
```

### Preopens

This is a more interesting example that features Zig's support for WebAssembly System Interface (WASI).
This code extracts the list of preopens from the runtime. This example is also different from the book
example, and is actually copied from Zig's online reference book.

```bash
cd chapter_17/preopens
# build
zig build-exe preopens.zig -target wasm32-wasi
# and run
wasmtime --dir=. preopens.wasm
0: stdin
1: stdout
2: stderr
3: .
```
