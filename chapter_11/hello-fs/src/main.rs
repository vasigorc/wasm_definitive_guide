use std::{
    env, fs,
    io::{Read, Write},
    path::PathBuf,
};

fn main() {
    let greeting = "Hello, world!";

    let home_dir_envvar =
        env::var("HOME").unwrap_or_else(|_| panic!("Could not determine home directory"));
    let mut file_path = PathBuf::from(home_dir_envvar);
    file_path.push("hello.txt");

    let outfile = file_path
        .to_str()
        .unwrap_or_else(|| panic!("Could not convert path to string"));

    let mut output_file = fs::File::create(outfile)
        .unwrap_or_else(|err| panic!("Error creating {}: {}", outfile, err));
    // write test as bytes to the file
    output_file
        .write_all(greeting.as_bytes())
        .unwrap_or_else(|err| panic!("Error writing to file {}: {}", outfile, err));

    // read from file
    let mut input_file = fs::File::open(outfile)
        .unwrap_or_else(|err| panic!("Error opening file {}: {}", outfile, err));
    let mut contents = String::new();
    input_file
        .read_to_string(&mut contents)
        .unwrap_or_else(|err| panic!("Error reading file {}: {}", outfile, err));

    println!("Contents of {}: {}", outfile, contents);
}
