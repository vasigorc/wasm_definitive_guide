# Chapter 12. Extending the WebAssembly Platform

In this chapter the author looks at different specifications that have sprung up and evolved since the WebAssembly MVP.

## WASI Runtimes

WASI introduced in the [previous chapter](/chapter_11/README.md) is a major vector for bringing new capabilities to WebAssembly. We saw basic usage of Wasmer, but the reality goes beyond that: it will be possible to execute arbitrary functionality from your own application using WASI-based mechanisms.

The example from this section shows the basics of using WebAssembly and WASI with some simple modules. [The example](chapter_12/hello-wasi) is a native
Rust application, not a WASI application, so it is therefore allowed to access the filesystem. The author used `Wasmtime` as the environment, and we are using `Wasmer`.

### Link common WAT file

For this exercise we will need the `hello.wat` age calculating module that was initially added in Chapter 2, and later moved to the [common](../common) folder.

```bash
ln -s ../common common
```

And, in order to build and run:

```bash
cargo build --release
   Compiling hello-wasi v0.1.0 (/home/vasilegorcinschi/repos/wasm_definitive_guide/chapter_12/hello-wasi)
    Finished `release` profile [optimized] target(s) in 0.55s
 vasilegorcinschi@bonobo15  ~/repos/wasm_definitive_guide/chapter_12/hello-wasi   main ±  cargo run --release
    Finished `release` profile [optimized] target(s) in 0.04s
     Running `target/release/hello-wasi`
You are 21
```

## Multi-value return

The point of this MVP is to be able to return two+ values from a function, similar to tuples in [Python](https://realpython.com/python-tuple/#returning-tuples-from-functions) or [Rust](https://doc.rust-lang.org/rust-by-example/primitives/tuples.html).

From Chapter 2, the result of a WebAssembly function is found at the top of the stack, so the top several elements
of the stack could be interpreted as multimple return values.

Unlike, the previous example, this one uses [Wasmtime](https://docs.wasmtime.dev/) (same, as in the book), and not [Wasmer](https://docs.wasmer.io/), just because
I failed to have a working example using `Wasmer` that would look equally concise as the `Wasmtime`'s - [link](https://github.com/wasmerio/wasmer/discussions/5647).

To compile and run the code, repeat the commands above but from within a new directory:

```bash
cargo build --release
    Compiling hello-mvr v0.1.0 (/home/vasilegorcinschi/repos/wasm_definitive_guide/chapter_12/hello-mvr)
     Finished `release` profile [optimized] target(s) in 0.56s
  vasilegorcinschi@bonobo15  ~/repos/wasm_definitive_guide/chapter_12/hello-mvr   main ±  cargo run --release
     Finished `release` profile [optimized] target(s) in 0.04s
      Running `target/release/hello-mvr`
 Swapping 13 and 43 produces 43 and 13.
```

## Reference Types

The previous sub-section could be viewed as a prerequisite for the specification described in this one: ability to specify references to opaque handlers, which
could serve as a bridge for adding garbage collection, having typed references, or using exception handling. At the same time, the goal of this specification
was to not let WebAssembly modules have access by default to opaque system resource references. This is achieved by manipulating `Table` members (recall from Chapter 7),
growing its instance size, and passing `externref` references between WebAssembly modules and their environments.

Once you build and run the [example](hello-extref/src/main.rs) it should print the following:

```bash
cargo run --release
    Finished `release` profile [optimized] target(s) in 0.05s
     Running `target/release/hello-extref`
Retrieved external reference: "secret key" from table slot 3
Retrieved external reference array: "[1, 2, 3, 4]" from table slot 4
Received "secret key" back from calling extern-ref aware function.`
```

## Module Linking

This last MVP is about allowing modules to be imported through a variety of mechanisms and styles: to have a dependency on a module that will provide this behavior
without having to import individual methods one by one. The strategy for achieving this is the ability to describe types of modules and allow different implementations
to satisfy those types. There is a new textual format for describing this way of interfacing in WebAssembly - files describing modules' dependencies end in _.wit_.

The example in this section uses `Wasmtime` runtime. This example shows linking of two modules: one that depends on the other and one that depends on having a WASI
capability of writing to the console. For this we must add `wasmtime-wasi` dependency. This is an implementation of the standard WASI functionality that we are
going to link against in the following example.

> In the [first module](hello-modlink/linking1.wat) we import a function called `double` that will take an `i32`, double it, and return an `i32`. We are also
> importing a convenience function called `log` that will print a string in a `Memory` at the given offset and of the given length.
> We will also import a `Memory` instance to use and a global variable representing an offset to use as the location of our activity.

The [second module](hello-modlink/linking2.wat) defines a type for a function that takes four `i32` parameters and returns an `i32`.

> This type will correspond to the `fd_write` method that we will import from the WASI namespace `wasi_snapshot_preview1`. There
> is also a simple function called `double` that loads the `i32` parameter sent in to the stack, follow-up with the constant 2,
> and then invokes the `i32.mul` instruction, which will pop off the top two stack values, multiply them, and write the result
> back to the top of the stack.

The exported `log` function invokes `fd_write`. This module also exports a `Memory` instance and a `global` variable indicating the current offset to write values into.

Note that the Rust code is slightly different than in the book - [`Wasmtime`'s example](https://github.com/bytecodealliance/wasmtime/blob/main/examples/linking.rs) evolves over time.

Building and running this examples prints:

```bash
cargo build --release
    Finished `release` profile [optimized] target(s) in 0.07s
cargo run --release
    Finished `release` profile [optimized] target(s) in 0.07s
     Running `target/release/hello-modlink`
Hello, world!
```
