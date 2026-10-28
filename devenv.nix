{
  pkgs,
  ...
}:

{
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

    # every chapter with a .wat file: language server (`wat_server`, lspconfig's wasm_language_tools) and formatter
    pkgs.wasm-language-tools

    # chapter_14/README.md: `asc hello.ts -o hello.wasm`
    pkgs.assemblyscript

    # chapter_02, 04, 05, 07, 09, 10: `python3 -m http.server 10003`
    pkgs.python3

    # chapter_06/bitmap/Makefile, chapter_09/Makefile: make; gcc for chapter_07 native C and cargo linking
    pkgs.gnumake
    pkgs.gcc

    # ~/repos/bash-utils/nix/nvim-module.nix: the editor itself
    pkgs.neovim
    pkgs.nodejs

    # nvim-module.nix: language servers matching this repo (rust-analyzer comes from languages.rust)
    pkgs.typescript-language-server
    pkgs.vscode-langservers-extracted
    pkgs.lua-language-server

    # nvim-module.nix: picker/search backends the nvim config shells out to
    pkgs.fzf
    pkgs.ripgrep

    # nvim-module.nix: used by the enterShell below to sync ~/.config/nvim into the isolated XDG dirs
    pkgs.rsync

    # nvim-module.nix: lazygit (+ lazygit-nvim)
    pkgs.lazygit

    # nvim-module.nix: marksman; this repo is chapter-by-chapter README.md notes
    pkgs.marksman

    # nvim-module.nix: "Nix tools"; for editing devenv.nix itself
    pkgs.nixfmt
    pkgs.statix
  ];

  # ~/repos/bash-utils/nix/nvim-module.nix shellHook, ported except for the data sync flags (see below): isolate
  # nvim/lazygit state under *-nix XDG dirs and copy the host nvim config/data into them (rsync only writes to the
  # *-nix copy)
  enterShell = ''
    export XDG_CONFIG_HOME="$HOME/.config-nix"
    export XDG_DATA_HOME="$HOME/.local-nix/share"
    export XDG_STATE_HOME="$HOME/.local-nix/state"
    export XDG_CACHE_HOME="$HOME/.cache-nix"

    mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME"

    if [ -d "$HOME/.config/nvim" ]; then
      echo "Syncing Neovim config from $HOME/.config/nvim"
      rsync -a --delete "$HOME/.config/nvim/" "$XDG_CONFIG_HOME/nvim/"
    fi

    # Deliberately differs from nvim-module.nix: `--delete` makes the plugin checkouts an exact copy of the host's.
    # Without it, plugins updated only inside this shell get their tracked files reverted to the host's versions on every
    # entry while their newer, untracked files stay, leaving a mixed plugin tree (e.g. CodeCompanion's
    # `stream_interval` nil error). The `P` rule keeps Mason packages installed only in this shell from being deleted.
    # Update plugins on the host, not in here.
    if [ -d "$HOME/.local/share/nvim" ]; then
      echo "Syncing Neovim data from $HOME/.local/share/nvim"
      rsync -a --delete --filter='P /mason/***' "$HOME/.local/share/nvim/" "$XDG_DATA_HOME/nvim/"
    fi

    # Deliberately differs from nvim-module.nix, which dumps `lazygit --config` here once. That dump pins the key syntax
    # of the lazygit that wrote it and is never refreshed, and newer lazygit versions reject old keys (e.g. `<c-R>` is
    # now `<ctrl+r>`), so lazygit refused to start. Mirror the host's config instead; with none, lazygit uses its defaults.
    if [ -d "$HOME/.config/lazygit" ]; then
      echo "Syncing lazygit config from $HOME/.config/lazygit"
      rsync -a --delete "$HOME/.config/lazygit/" "$XDG_CONFIG_HOME/lazygit/"
    fi
  '';

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

  enterTest = ''
    check-tools
  '';
}
