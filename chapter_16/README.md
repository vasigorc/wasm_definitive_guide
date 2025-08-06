# Applied WebAssembly: Decentralized Applications

This micro-project exemplifies support for the concept of "fuel" (or "gas"), that is used in [Ethereum](https://en.wikipedia.org/wiki/Ethereum):

> Ethereum contract is evaluated with a quick heuristic to determine roughly how expensive it will be
> to run, and the client launching the contract has to cough up that much or more. As the contract executes,
> it consumes gas and can run out. If it does, the nodes get compensated for effort and you may be left
> with nothing...It...forces contract developers to exercise caution and test their code locally.

```bash
cargo run
   Compiling wasmtime-fuel v0.1.0 (/home/vasilegorcinschi/repos/wasm_definitive_guide/chapter_16/wasmtime-fuel)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 3.29s
     Running `target/debug/wasmtime-fuel`
fib(1) = 1 [consumed 6 fuel]
fib(2) = 1 [consumed 26 fuel]
fib(3) = 2 [consumed 46 fuel]
fib(4) = 3 [consumed 86 fuel]
fib(5) = 5 [consumed 146 fuel]
fib(6) = 8 [consumed 246 fuel]
fib(7) = 13 [consumed 406 fuel]
fib(8) = 21 [consumed 666 fuel]
fib(9) = 34 [consumed 1086 fuel]
fib(10) = 55 [consumed 1766 fuel]
fib(11) = 89 [consumed 2866 fuel]
fib(12) = 144 [consumed 4646 fuel]
fib(13) = 233 [consumed 7526 fuel]
Exhausted fuel computing fib(14)
```

1 fuel unit is roughly equal to 1 instruction on the Wasm VM.

Besides Ethereum gas, other real-world use cases for Wasmtime's fuel system could include:

1. **Serverless/FaaS Platforms**

Fuel can be used to deterministically prevent infinitely-executing WebAssembly code by instrumenting
generated code to consume fuel as it execute. Cloud providers use this to:

- **Prevent runaway functions** from consuming unlimited CPU
- **Implement fair billing** based on actual computation used
- **Enforce execution limits** per function invocation

2. **Multi-tenant SaaS Applications**

When running multiple customers' code in the same process:

- **Fair resource allocation** - each tenant gets equal CPU time
- **Isolation** - one tenant's infinite loop can't starve others
- **SLA enforcement** - guarantee each request gets minimum computation

```rust
// Each customer request gets fair share
for request in requests {
    store.set_fuel(10_000); // Fair share per request
    process_customer_plugin(&mut store, request);
}
```

3. **Plugin/Extension Systems**

Applications that allow user-provided plugins (like VS Code extensions, but in WASM):

- **Prevent malicious plugins** from hanging the host application
- **Cooperative multitasking** - plugins yield control periodically
- **Performance budgets** - plugins can't exceed allocated computation

4. **Educational Platforms & Code Judges**

Online coding platforms like HackerRank, LeetCode:

- **Prevent infinite loops** in student/competitor code
- **Consistent grading** - same algorithm gets same score regardless of hardware
- **Time complexity measurement** - fuel consumption correlates with algorithm complexity
