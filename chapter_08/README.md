# Chapter 08. WebAssembly in the Server

This chapter deals with using WebAssembly in typical Javascript backends: Node.js and Deno.

Here are a few excerpts from the book:

On speaking about _Native Extensions to Node.js_, The issue is largely the fact that C and C++ code
has direct access to memory but Javascript code does not.

In Node.js, there has historically been middleware like Express and then native add-ons written in C and C++.

In order to use C/C++ code within Node.js one would need `node-gyp` command installed. The book then gives an
example of how to make `adddon.c` code usable from within Javascript:

```shell
# from within the directory where adddon.c resides
node-gyp configure build
```

```javascript
// test.js
const adddon = require("./build/Release/adddon");

console.log("This should be eight: ", adddon.add(3, 5));
```

I didn't use those examples in this repository, as I wanted to concentrate on WebAssembly integration instead.

## WebAssembly and Node.js

Test that [`add.c`](./node/add.c) is working:

```shell
 vasilegorcinschi@bonobo15  ~/repos/wasm_definitive_guide/chapter_08/node   main ±  clang add.c
 vasilegorcinschi@bonobo15  ~/repos/wasm_definitive_guide/chapter_08/node   main ±  ./a.out
The sum of 2 and 3 is: 5
```

We have to update the code to make it useable with Emscripten: add Emscripten-related macros. For contrast,
I created another file: [`add_emscripten.c`](./node/add_emscripten.c). Here is how you can compile it to Javascript
and run it on Node:

```javascript
vasilegorcinschi@bonobo15  ~/repos/wasm_definitive_guide/chapter_08/node/   main ±  emcc add_emscripten.c
vasilegorcinschi@bonobo15  ~/repos/wasm_definitive_guide/chapter_08/node   main ±  node a.out.js
The sum of 2 and 3 is: 5
```

Node.js provides experimental support for loading WebAssembly modules as ES6 modules, check [`index.mjs`](./node/index.mjs) file and note the
file extension. Note, however, that so that the next works I had to comment the `main` method in `add_emscripten.c` You may run this as such:

```shell
# recompile add_emscripten.c, else it will fail with `Error [ERR_MODULE_NOT_FOUND]: Cannot find package 'wasi_snapshot_preview1'`
 ✘ vasilegorcinschi@bonobo15  ~/repos/wasm_definitive_guide/chapter_08/node   main ±  emcc add_emscripten.c
 vasilegorcinschi@bonobo15  ~/repos/wasm_definitive_guide/chapter_08/node   main ±  node --experimental-modules --experimental-wasm-modules index.mjs
(node:363003) ExperimentalWarning: Importing WebAssembly modules is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
The sum of 6 and 2 is: 8
```
