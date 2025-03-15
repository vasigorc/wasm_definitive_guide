# Chapter 11: WebAssembly System Interface (WASI)

The are some things that are unnecessarily diffficult in WebAssembly
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
will not be able to run on a Linux host (previously we able to use `.wasm` file in the browser).
