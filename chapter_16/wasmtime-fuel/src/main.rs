use anyhow::Result;
use wasmtime::*;

fn main() -> Result<()> {
    let mut config = Config::new();
    config.consume_fuel(true);
    let engine = Engine::new(&config)?;
    let mut store = Store::new(&engine, ());
    store.set_fuel(10_000)?;
    let module = Module::from_file(store.engine(), "fuel.wat")?;
    let instance = Instance::new(&mut store, &module, &[])?;

    // Invoke `fibonacci` export with higher and higher numbers until we
    // exhaust out fuel
    let fibonacci = instance.get_typed_func::<i32, i32>(&mut store, "fibonacci")?;

    for n in 1.. {
        let fuel_before = store.get_fuel().unwrap();
        let output = match fibonacci.call(&mut store, n) {
            Ok(v) => v,
            Err(_) => {
                println!("Exhausted fuel computing fib({n})");
                break;
            }
        };
        let current_fuel = store.get_fuel().unwrap();
        let fuel_consumed = fuel_before - current_fuel;
        println!("fib({n}) = {output} [consumed {fuel_consumed} fuel]");
        store.set_fuel(current_fuel + fuel_consumed)?
    }
    Ok(())
}
