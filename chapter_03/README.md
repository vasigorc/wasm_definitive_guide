# Chapter 3. WebAssembly Modules

`hellolog.wasm` is already there, but you could have generated it like so:

```shell
cd chapter_03/
wat2wasm hellolog.wat
```

Hew is how you can inspect the module use CLI inspection tool:

```shell
➜  chapter_03 git:(main) ✗ wasm-objdump -x hellolog.wasm

hellolog.wasm:  file format wasm 0x1

Section Details:

Type[3]:
 - type[0] (i32) -> nil
 - type[1] (i32, i32) -> i32
 - type[2] (i32, i32) -> nil
Import[1]:
 - func[0] sig=0 <imports.log_func> <- imports.log_func
Function[2]:
 - func[1] sig=1 <how_old>
 - func[2] sig=2 <log_how_old>
Export[2]:
 - func[1] <how_old> -> "how_old"
 - func[2] <log_how_old> -> "log_how_old"
Code[2]:
 - func[1] size=7 <how_old>
 - func[2] size=10 <log_how_old>
 ```

 ## Link common JS and CSS files

```shell
# supposing you are in chapter_03 folder already
ln -s ../common common
```

To preview [index.html](index.html) file that runs [hellolog.wasm](hellolog.wasm) file the instructed step is:

```shell
# assumes presence of python3 on your host system
python3 -m http.server 10003
```