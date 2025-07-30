# Using AssemblyScript and WebAssembly

AssemblyScript is a Binaryen-based compiler that turns a subset of TypeScript into WebAssembly.
It is obviously similar to Typescript.

> AssemblyScript is an attempt to provide a JavaScript-like (and, more to the point TypeScript-like)
> experience but with the performance and security WebAssembly offers.

## Differences with TypeScript

Unlike TypeScript, AssemblyScript does not support `any` and `undefined`, neither does it support
`union` types.

> Because AssemblyScript is compiled into Wasm, it has no ability to do anything with network connections,
> filesystem access, or DOM manipulation, just like any other module. Those have to be provided through
> import objects or through WASI.

> AssemblyScript lives close to eh WebAssembly instruction set we have seen throughout the book. The numeric
> types are basically what you would imagine them to be, including `i32`, `i64`, `f32`, `f64` and `usize`, which
> is used for indexing memory.

There is no support for implementing interfaces, closures, exceptions, or access modifiers for classes
(`public`, `private`, or `protected`).

## Simple example

The command to generate a WebAssembly file from a TypeScript file is a little different than it was at the
time of writing of book (`-o` instead of `-b`):

```bash
asc -h | grep -A 4 Output
 Output

  --outFile, -o         Specifies the WebAssembly output file (.wasm).
  --textFile, -t        Specifies the WebAssembly text output file (.wat).
  --bindings, -b        Specifies the bindings to generate (.js + .d.ts).
asc hello.ts -o hello.wasm
ls -alF
total 16
drwxr-xr-x 2 vasilegorcinschi vasilegorcinschi 4096 Jul 28 20:41 ./
drwxr-xr-x 3 vasilegorcinschi vasilegorcinschi 4096 Jul 28 07:59 ../
-rw-r--r-- 1 vasilegorcinschi vasilegorcinschi   60 Jul 28 07:59 hello.ts
-rw-r--r-- 1 vasilegorcinschi vasilegorcinschi   93 Jul 28 20:41 hello.wasm
```

Further analyzing the generated WebAssembly file reveals that the compiler generated a `Memory` instance and
an export for it. The compiler has also the function defined in the `hello.ts` file by adorning it with
the keyword `export`. This makes it easy to use it from JavaScript:

```bash
wasm-objdump -x hello.wasm

hello.wasm: file format wasm 0x1

Section Details:

Type[1]:
 - type[0] (i32, i32) -> i32
Function[1]:
 - func[0] sig=0 <add>
Table[1]:
 - table[0] type=funcref initial=1 max=1
Memory[1]:
 - memory[0] pages: initial=0
Global[3]:
 - global[0] i32 mutable=0 - init i32=8
 - global[1] i32 mutable=1 - init i32=32776
 - global[2] i32 mutable=0 - init i32=32776
Export[2]:
 - func[0] <add> -> "add"
 - memory[0] -> "memory"
Elem[1]:
 - segment[0] flags=0 table=0 count=0 - init i32=1
Code[1]:
 - func[0] size=8 <add>
```

For this example we will need the static files that were initially added in Chapter 2, and later moved to the [common](../common) folder.

```bash
ln -s ../common common
```

Run the server from the chapter's root in order that Python's HTTP server can access `common` files:

```bash
python3 -m http.server 10003
```

If you then navigate to `http://localhost:10003/hello`, and open console, you should see `42` printed out.

## Working with the `Memory` model

The example in the [as-mem](as_mem) directory highlights how working with a `Memory`'s module instance is possible. Here
we grow the memory by a page to make sure that we have 64K of memory.

## Garbage Collection and the AssemblyScript Runtime

A convenient way of interacting with garbage collection will be showcases later in this section. One may use GC if you tell
AssemblyScript compiler to export access to the runtime with the `--exportRuntime` directive.

> Not only that, you have the option of controlling the behavior of the runtime by using the `--runtime` parameter. This allows
> you to specify whether it should use an incremental, minimal, stub, or even a custom pluggable implementation.

So it is possible to allocate memory from a module's exported `Memory` instance, and pin and unpin references that point
into it so that they will or will not be collected _by other processes_.

## AssemblyScript Standard Library

[`stdlib` from AssemblyScript](https://www.assemblyscript.org/stdlib/globals.html) is a handy library that offers
functionality of a modern programming infrastructure. This section highlights some of that by building a set of functions
calculating details of a circle. See [stdlib](stdlib).

> Because AssemblyScript defaults to `f64` numbers, we cast them to `f32` numbers before returning the values from the
> functions.

The output in a browser's console (same steps as above to run the example):

```javascript
Diameter of a circle for a radius 2.0:4
Circumference of a circle for a radius 2.0:12.566370964050293
Area of a circle for a radius 2.0:12.566370964050293
```

## AssemblyScript Loader

To exemplify the use of the `Loader`, the author actually pulled the AssemblyScript's [examples repo](https://github.com/AssemblyScript/examples) and used
the [loader](https://github.com/AssemblyScript/examples/tree/main/loader) example.
