# WebAssembly. The Definitive Guide

This is a walkthrough of the O'Reilly book by Brian Sletten

![WebAssembly the Definitive Guide](images/wasm_book.png)

## Required tools

In order to run examples from this repository you will need a few tools installed on your machine:

### wabt

Follow this [link](https://github.com/WebAssembly/wabt?tab=readme-ov-file#installing-prebuilt-binaries) to install
pre-build binaries. E.g. for Fedora I used:

```shell
sudo dnf install wabt
```

### wasm3

I actually installed it from source.

#### For Fedora

```shell
# install missing dependencies
sudo dnf install git cmake gcc-c++ make

# clone the sources
# and build in a `build` directory
git clone https://github.com/wasm3/wasm3.git
cd wasm3
mkdir build
cd build
cmake ..

# install system-wide
sudo make install

# test installation
➜  wasm_definitive_guide git:(main) wasm3 --version                               
Wasm3 v0.5.1 on x86_64
Build: Dec 27 2024 15:34:31, GCC 13.3.1 20240913 (Red Hat 13.3.1-3)
```

#### For Ubuntu / POP!_OS


```shell
# install missing dependencies
sudo apt install git cmake g++ make

# clone the sources
# and build in a `build` directory
git clone https://github.com/wasm3/wasm3.git
cd wasm3
mkdir build
cd build
cmake ..

# install system-wide
sudo make install

# test installation
➜  wasm_definitive_guide git:(main) wasm3 --version                               
...
```
