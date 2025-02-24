# Chapter 9. Applied WebAssembly: TensorFlow.js

This is the first of the _Applied WebAssembly_ chapters, where potential use cases for WebAssembly are highlighted.

This chapter touches upon scenarios of leveraging Machine Learning directly in the browser, potentially, as we will
try to demonstrate, even relying on the underlying platform's acceleration (GPUs in our case).

Some key ideas from the chapter's theory is that as computer hardware gets more and more sophisticated, it takes
time and power to compute things. _A big part of a successful IT strategy moving forward is going to be about minimizing
time costs, power costs, and latency costs...In order to process data in reasonable amounts of time, we need acccess to
hardware acceleration._

## TensorFlow.js

_The design of the TensorFlow.js framework is elegant and results in clean APIs that work across a wide range of devices.
Rather than limiting the implementation to what is available everywhere, the designers chose to create a pluggable backend
to cover the wildest number of systems._

_There is no direct support for accessing GPUs from JavaScript, but there is via WebGL._

_The applications written against (Layers API (inspired from Keras) or Ops API) will be portable across all of the environments
covered by the backends. That includes in the browser, out of the browser, with hardware acceleration and without._

The list of supported backends:

- CPU JavaScript backend
- WebGL JavaScript backend
- CPU (+AVX) native backend
- GPU native backend
- TPU native backend
- WASM backend

Hence, we see _a strategy for isolating the bits that change and taking advantage of the hardware options available to us._

The book itself didn't give an example of a POC project running WebGl, TensorFlow.js and native code compiled to WASM, so we
tried to contrive one ourselves, not without help from Claude AI, lo siento! As a bonus, we will try to trigger and monitor the
usage of native RTX 4080 Nvidia GPUs.
