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

There is no support for implementing interfaces, closures, exceptions, or access modifiers for classes
(`public`, `private`, or `protected`).
