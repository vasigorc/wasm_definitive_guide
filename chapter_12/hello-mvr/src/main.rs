use std::error::Error;

use wasmer::*;

fn main() -> Result<(), Box<dyn Error>> {
    let compiler = Cranelift::new();
    let engine = Engine::default();
    let mut store = Store::new((compiler));
    let module = Module::from_file(&engine, "mvr.wat");
    let import_object = imports! {};

    let callback_func = Function::new_typed(&mut store, |a: i32, b: i32| -> (i32, i32) { (b, a) });

    let instance = Instance::new(&mut store, &module, &[callback_func.into()])?;

    let myfunc = instance
        .exports
        .get_typed_function::<(i32, i32), (i32, i32)>(&mut store, "myfunc")?;
    let (a, b) = myfunc.call(&mut store, 13i32, 43i32)?;
    println!("Swapping {} and {} produces {} and {}.", 13, 43, a, b);

    Ok(())
}
