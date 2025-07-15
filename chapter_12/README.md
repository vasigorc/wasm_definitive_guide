# Chapter 12. Extending the WebAssembly Platform

In this chapter the author looks at different specifications that have sprung up and evolved since the WebAssembly MVP.

## WASI Runtimes

WASI introduced in the [previous chapter](/chapter_11/README.md) is a major vector for bringing new capabilities to WebAssembly. We saw basic usage of Wasmer, but the reality goes beyond that: it will be possible to execute arbitrary functionality from your own application using WASI-based mechanisms.

The example from this section shows the basics of using WebAssembly and WASI with some simple modules. [The example](chapter_12/hello-wasi) is a native
Rust application, not a WASI application, so it is therefore allowed to access the filesystem. The author used `Wasmtime` as the environment, and we are using `Wasmer`.

## Link common JS and CSS files

For this exercise we will need the `hello.wat` age calculating module that was initially added in Chapter 2, and later moved to the [common](../common) folder.

```bash
ln -s ../common common
```
