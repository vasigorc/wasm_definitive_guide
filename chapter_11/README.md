# Chapter 11: WebAssembly System Interface (WASI)

There are some things that are unnecessarily diffficult in WebAssembly
as a consequence of the security and safety goals, e.g.: reading from
the file system, writing to the console, or manipulating strings. WebAssembly
modules, by themselves, do not have access to anything that is not explicitly
provided by their hosting environment.

Until this chapter we saw how to make code portable. In this chapter we are
invited to learn how to make applications portable.

## WebAssembly System Interface (WASI)

Most previously encountered examples worked out of the box because they
were run in browser. This is expected, a browser is a host to other code.
Despite some security restrictions, it is a featureful programming environment,
with 3D graphics, accelerated video, WebRTC, and more.

Runtime environments outside of the browser also represent WebAssembly's potential
execution surface, but their APIs are not directly compatible with the browser
or with each other. POSIX functions will be consistent across different
environments, mapping to lower-level kernel calls, allowing for more portable applications.

One of the problems that WASI attempts to solve is having an ecosystem of functionality
that programs permitted to access it can expect to be available: a functionality
which would work across programming languages and environments.

A simple `hello world` application written in Rust and compiled for WASM target
will not be able to run on a Linux host (remember, previously we were able to use file 
built for this target in the browser).

```shell
vasilegorcinschi@bonobo15  ~/repos/wasm_definitive_guide/chapter_11/hello-world   main ±  cargo build --target wasm32-unknown-unknown --release
    Finished `release` profile [optimized] target(s) in 0.00s
 vasilegorcinschi@bonobo15  ~/repos/wasm_definitive_guide/chapter_11/hello-world   main ±  ls -halF target/wasm32-unknown-unknown/release
total 80K
drwxrwxr-x 7 vasilegorcinschi vasilegorcinschi 4.0K Mar 15 l5:51 ./
drwxrwxr-x 3 vasilegorcinschi vasilegorcinschi 4.0K Mar h15:51 ../
-rw-rw-r-- 1 vasilegorcinschi vasilegorcinschi    0 Mar 15 h1 .cargo-lock
drwxrwxr-x 3 vasilegorcinschi vasilegorcinschi 4.0K Mar 15 15:51 .fingerprint/
drwxrwxr-x 2 vasilegorcinschi vasilegorcinschi 4.0K Mar 15 15:51 build/
drwxrwxr-x 2 vasilegorcinschi vasilegorcinschi 4.0K Mar 15 15:51 deps/
drwxrwxr-x 2 vasilegorcinschi vasilegorcinschi 4.0K Mar 15 15:51 examples/
-rw-rw-r-- 1 vasilegorcinschi vasilegorcinschi  216 Mar 15 15:51 hello-world.d
-rwxrwxr-x 2 vasilegorcinschi vasilegorcinschi  48K Mar 15 15:51 hello-world.wasm*
drwxrwxr-x 2 vasilegorcinschi vasilegorcinschi 4.0K Mar 15 15:51 incremental/
 vasilegorcinschi@bonobo15  ~/repos/wasm_definitive_guide/chapter_11/hello-world   main ±  wasmer target/wasm32-unknown-unknown/release/hello-world.wasm
error: The module doesn't export a "_start" function. Either implement it or specify an entry function with --invoke
╰─▶ 1: Missing export _start
```

A basic WASM module does not define the same type of application binary interface ([ABI](https://en.wikipedia.org/wiki/Application_binary_interface))
that an executable program does The referenced `_start` function, that `wasmer` expected in the
example above - it is the method that calls the `main` function.

If we were to change the targeted platform from `wasm-*` to `wasi-*` things would change:

```shell
 ✘ vasilegorcinschi@bonobo15  ~/repos/wasm_definitive_guide/chapter_11/hello-world   main ±  cargo build --target wasm32-wasi --release
   Compiling hello-world v0.1.0 (/home/vasilegorcinschi/repos/wasm_definitive_guide/chapter_11/hello-world)
    Finished `release` profile [optimized] target(s) in 0.23s
 vasilegorcinschi@bonobo15  ~/repos/wasm_definitive_guide/chapter_11/hello-world   main ±  wasmer target/wasm32-wasi/release/hello-world.wasm
Hello, world!
vasilegorcinschi@bonobo15  ~/repos/wasm_definitive_guide/chapter_11/hello-world   main ±  wasm-objdump -x target/wasm32-wasi/release/hello-world.wasm | grep -A 3 Export
Export[3]:
 - memory[0] -> "memory"
 - func[5] <_start> -> "_start"
 - func[11] <__main_void> -> "__main_void"
```

When compiled for the `wasi-*` target, the WASM module exports a `_start` function that is responsible 
for calling the `main` function. WASI also provides a convenient way for a WASM module to _import_ functionality
that it needs to execute. `wasm32-wasi` backend emits calls to a standard library that will be provided by
the host environment where our code will run.

The samw WASI form of the WebAssembly module will run on Linux or Windows. WebAssembly makes the code
portable, WASI does the same thing to your application by compyling with the host's expectactions.
