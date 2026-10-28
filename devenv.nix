{
  pkgs,
  lib,
  ...
}:

let
  # My personal Neovim set-up (editor, language servers, lazygit, host config sync). Imported only when bash-utils is
  # cloned under ~/repos, so the environment still evaluates for everyone else. Needs impure evaluation, devenv's default.
  nvimModule = "${builtins.getEnv "HOME"}/repos/bash-utils/devenv/nvim.nix";
in
{
  imports = lib.optional (builtins.pathExists nvimModule) nvimModule;

  # chapter_10..12, 16: cargo projects (edition 2024 needs a recent stable) and `rustc --target wasm32-unknown-unknown`
  # (chapter_10/README.md). chapter_11/README.md builds for wasm32-wasip1. Replaces the rustup shellHook of
  # ~/repos/bash-utils/nix/compiled-module.nix.
  languages.rust = {
    enable = true;
    channel = "stable";
    targets = [
      "wasm32-unknown-unknown"
      "wasm32-wasip1"
    ];
  };

  # chapter_08/deno/deno.jsonc, chapter_08/node/index.mjs, chapter_14 (asc + .ts), js-module.nix
  languages.javascript.enable = true;
  languages.deno.enable = true;
  languages.typescript.enable = true;

  # chapter_17/README.md: `zig build-exe ... -target wasm32-freestanding` / `wasm32-wasi`
  languages.zig.enable = true;

  packages = [
    # chapter_02..04, 07, 12: wat2wasm and wasm-objdump (README.md "wabt")
    pkgs.wabt

    # chapter_10, 11, 12: `wasmer run`; chapter_17: `wasmtime --dir=. preopens.wasm`
    pkgs.wasmer
    pkgs.wasmtime

    # chapter_10/README.md "hello-wasm-bindgen ... relies on wasm-pack to build the module"
    pkgs.wasm-pack

    # chapter_05..09: emcc / em++ (chapter_06/bitmap/Makefile, chapter_09/Makefile)
    pkgs.emscripten

    # chapter_08/node/add.c is built with plain `clang`; chapter_05 uses clang --target=wasm32 (README.md "LLVM")
    pkgs.clang
    pkgs.llvmPackages.llvm
    # README.md "LLVM": wasm-ld, shipped by lld
    pkgs.lld

    # every chapter with a .wat file: language server (`wat_server`) and formatter
    pkgs.wasm-language-tools

    # chapter_14/README.md: `asc hello.ts -o hello.wasm`
    pkgs.assemblyscript

    # chapter_02, 04, 05, 07, 09, 10: `python3 -m http.server 10003`
    pkgs.python3

    # chapter_06/bitmap/Makefile, chapter_09/Makefile: make; gcc for chapter_07 native C and cargo linking
    pkgs.gnumake
    pkgs.gcc
  ];

  # smoke test for every toolchain the chapters depend on; run with `check-tools` inside the shell
  scripts.check-tools.exec = ''
    set -e
    wat2wasm --version
    wasm-objdump --version
    wasmer --version
    wasmtime --version
    wasm-pack --version
    emcc --version | head -1
    clang --version | head -1
    wasm-ld --version
    command -v wat_server # LSP server for .wat files, no --version: it only speaks LSP on stdio
    asc --version
    zig version
    deno --version | head -1
    node --version
    tsc --version
    python3 --version
    rustc --version
    rustc --print target-libdir --target wasm32-unknown-unknown
    rustc --print target-libdir --target wasm32-wasip1
  '';

  # devenv 2.4 lists this task as "no command" and never runs it, so `devenv test` does not check anything;
  # use `check-tools` directly
  enterTest = ''
    check-tools
  '';
}
