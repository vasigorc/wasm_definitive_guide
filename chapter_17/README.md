# WebAssembly and Other Languages

## Zig

The syntax for building a "freestanding" WebAssembly module in Zig has changed since
the time of the writing of the book. The new syntax looks like this:

```bash
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
