use std::error::Error;

use wasmer::*;

fn main() -> Result<(), Box<dyn Error>> {
    let compiler = Cranelift::new();
    let engine = Engine::default();
    let mut store = Store::new(compiler);
    let module = Module::from_file(&engine, "../common/hello.wat")?;
    let import_object = imports! {};
    let instance = Instance::new(&mut store, &module, &import_object)?;

    let how_old = instance
        .exports
        .get_typed_function::<(i32, i32), i32>(&mut store, "how_old")?;
    let age: i32 = how_old.call(&mut store, 2021i32, 2000i32)?;

    println!("You are {}", age);

    Ok(())
}
