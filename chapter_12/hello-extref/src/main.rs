use std::error::Error;

use wasmer::{
    ExternRef, Instance, Module, Store, imports,
    sys::{Cranelift, EngineBuilder, Features},
};

fn main() -> Result<(), Box<dyn Error>> {
    let compiler = Cranelift::default();
    let mut features = Features::new();
    features.reference_types(true);

    let engine = EngineBuilder::new(compiler)
        .set_features(Some(features))
        .engine();

    let mut store = Store::new(engine);
    let module = Module::from_file(&store, "extref.wat")?;

    let import_object = imports! {};
    let instance = Instance::new(&mut store, &module, &import_object)?;

    let eref = ExternRef::new(&mut store, "secret key");
    let arr: [u8; 4] = [1, 2, 3, 4];

    let eref2 = ExternRef::new(&mut store, arr);

    let table = instance.exports.get_table("table").unwrap();
    table.set(&mut store, 3, Some(eref.clone()).into())?;
    table.set(&mut store, 4, Some(eref2.clone()).into())?;

    if let Some(s) = get_externref::<&'static str>(table, &mut store, 3) {
        println!(
            "Retrieved external reference: \"{}\" from table slot {}",
            s, 3
        );
    }

    if let Some(a) = get_externref::<[u8; 4]>(table, &mut store, 4) {
        println!(
            "Retrieved external reference array: \"{:?}\" from table slot {}",
            a, 4
        );
    }

    Ok(())
}

fn get_externref<'a, T: 'static + std::marker::Sync + std::marker::Send>(
    table: &wasmer::Table,
    store: &'a mut Store,
    idx: u32,
) -> Option<&'a T> {
    table
        .get(store, idx)?
        .unwrap_externref()
        .as_ref()
        .and_then(|r| r.downcast::<T>(store))
}
