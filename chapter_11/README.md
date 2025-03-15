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

## Capabilities-Based Security

Similarly to WebAssembly not granting arbitrary code access to memory, WASI does not give access to 
resources, such as file handles or network connections, process files, etc. Instead, these resources
will be made available via unforgeable, opaque handles that provide "the capability to the code".

In the following example we have a program that:
- creates a file
- writes some text to it
- reads that text back in

At the time of writing of this book, this code was designed somewhat different, in that the file was
written to the current directory, and WASI runtime would complain about not being
able to obtain file handle - we were required to explicitly specify the file path with `--dir=.` flag.

The fact that the run time requirements changed over time which reflects  the evolution of
the WASI specification:

1. **Default preopened directories**: newer versions of `wasmer` runtime include
current directory (just like `/tmp`) as a default preopened directory.
2. **Refined capability-based security**: while the security model remains
intact, the implementation details and default granted capabilities have 
been refined.

To prove the initial point and intent of this exercise we will instead try to
create the same file in the _$HOME_ directory. We'll compile this program with the
`wasm32-wasi` target and run it with `wasmer`, just as we did in the previous example:

```shell
 ✘ vasilegorcinschi@bonobo15  ~/repos/wasm_definitive_guide/chapter_11/hello-fs   main ±  wasmer run target/wasm32-wasi/release/hello-fs.wasm --dir=$HOME
thread 'main' panicked at src/main.rs:11:45:
Could not determine home directory
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
error: RuntimeError: unreachable
    at __rust_start_panic (hello_fs-d54b545e31f6233f.wasm[128]:0x604e)
    at rust_panic (hello_fs-d54b545e31f6233f.wasm[123]:0x5dfd)
    at std::panicking::rust_panic_with_hook::h5aa58467fd511e58 (hello_fs-d54b545e31f6233f.wasm[122]:0x5b21)
    at std::panicking::begin_panic_handler::{{closure}}::hddafbb74422ab5b5 (hello_fs-d54b545e31f6233f.wasm[111]:0x4f6b)
    at std::sys_common::backtrace::__rust_end_short_backtrace::hee1cd7216ef8c172 (hello_fs-d54b545e31f6233f.wasm[110]:0x4e9b)
    at rust_begin_unwind (hello_fs-d54b545e31f6233f.wasm[117]:0x5629)
    at core::panicking::panic_fmt::hdff7d27056516045 (hello_fs-d54b545e31f6233f.wasm[204]:0xb46c)
    at hello_fs::main::hbe56440db5fa7da6 (hello_fs-d54b545e31f6233f.wasm[19]:0x70c)
    at std::sys_common::backtrace::__rust_begin_short_backtrace::h2793ed32608d29ba (hello_fs-d54b545e31f6233f.wasm[13]:0x475)
    at std::rt::lang_start::{{closure}}::h479714d13e673507 (hello_fs-d54b545e31f6233f.wasm[14]:0x484)
    at std::rt::lang_start_internal::hdc5a291adcbf2591 (hello_fs-d54b545e31f6233f.wasm[75]:0x29a1)
    at __main_void (hello_fs-d54b545e31f6233f.wasm[20]:0xa9d)
    at _start (hello_fs-d54b545e31f6233f.wasm[12]:0x450)
╰─▶ 1: RuntimeError: unreachable
           at __rust_start_panic (hello_fs-d54b545e31f6233f.wasm[128]:0x604e)
           at rust_panic (hello_fs-d54b545e31f6233f.wasm[123]:0x5dfd)
           at std::panicking::rust_panic_with_hook::h5aa58467fd511e58 (hello_fs-d54b545e31f6233f.wasm[122]:0x5b21)
           at std::panicking::begin_panic_handler::{{closure}}::hddafbb74422ab5b5 (hello_fs-d54b545e31f6233f.wasm[111]:0x4f6b)
           at std::sys_common::backtrace::__rust_end_short_backtrace::hee1cd7216ef8c172 (hello_fs-d54b545e31f6233f.wasm[110]:0x4e9b)
           at rust_begin_unwind (hello_fs-d54b545e31f6233f.wasm[117]:0x5629)
           at core::panicking::panic_fmt::hdff7d27056516045 (hello_fs-d54b545e31f6233f.wasm[204]:0xb46c)
           at hello_fs::main::hbe56440db5fa7da6 (hello_fs-d54b545e31f6233f.wasm[19]:0x70c)
           at std::sys_common::backtrace::__rust_begin_short_backtrace::h2793ed32608d29ba (hello_fs-d54b545e31f6233f.wasm[13]:0x475)
           at std::rt::lang_start::{{closure}}::h479714d13e673507 (hello_fs-d54b545e31f6233f.wasm[14]:0x484)
           at std::rt::lang_start_internal::hdc5a291adcbf2591 (hello_fs-d54b545e31f6233f.wasm[75]:0x29a1)
           at __main_void (hello_fs-d54b545e31f6233f.wasm[20]:0xa9d)
           at _start (hello_fs-d54b545e31f6233f.wasm[12]:0x450)
```

Now, with the newer version of `wasmer` we would have to explictly specify that we want to allow access to _$HOME_ and pass
the `$HOME` environment variable to the WASI runtime:

```shell
 ✘ vasilegorcinschi@bonobo15  ~/repos/wasm_definitive_guide/chapter_11/hello-fs   main ±  wasmer run target/wasm32-wasi/release/hello-fs.wasm --dir=$HOME --env HOME=$HOME
Contents of /home/vasilegorcinschi/hello.txt: Hello, world!
```