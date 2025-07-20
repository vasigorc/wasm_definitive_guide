use std::error::Error;

use wasmer::*;

fn main() -> Result<(), Box<dyn Error>> {
    let mut store = Store::default();
    let module = Module::from_file(&store, "mvr.wat")?;

    let callback_func = Function::new_typed(&mut store, |a: i32, b: i32| -> (i32, i32) { (b, a) });

    let import_object = imports! {
        "" => {
            "swap" => callback_func,
        }
    };

    let instance = Instance::new(&mut store, &module, &import_object)?;

    let myfunc = instance
        .exports
        .get_typed_function::<(i32, i32), (i32, i32)>(&mut store, "myfunc")?;
    let (a, b) = myfunc.call(&mut store, 13i32, 43i32)?;
    println!("Swapping {} and {} produces {} and {}.", 13, 43, a, b);

    Ok(())
}
