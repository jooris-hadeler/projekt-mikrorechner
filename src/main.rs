use std::{
    fs,
    io::{stdin, stdout, Write},
    process::exit,
};

use clap::Parser;
use cli::Cli;
use emulator::Emulator;
use isa::*;
use log::LevelFilter;
use yansi::Paint;

mod asm;
mod cli;
mod emulator;
mod isa;

fn main() {
    let args = Cli::parse();

    simple_logger::SimpleLogger::new()
        .with_colors(true)
        .with_level(if args.verbose {
            LevelFilter::Debug
        } else {
            LevelFilter::Warn
        })
        .without_timestamps()
        .init()
        .expect("failed to init logger");

    let Ok(rom) = fs::read(&args.file) else {
        eprintln!("{} failed to load rom image.", "error:".bright_red());
        exit(-1);
    };

    let rom_converted = convert_to_word_vec(rom);

    let mut emulator = Emulator::new(rom_converted, args.ram_size, args.entry);
    while !emulator.should_halt() {
        emulator.print_instructions();
        emulator.tick();

        print!("cmd> ");

        let mut buf = String::new();
        stdout().flush().unwrap();
        stdin().read_line(&mut buf).unwrap();
    }
}

fn convert_to_word_vec(vec: Vec<u8>) -> Vec<u32> {
    let mut result = Vec::new();

    for i in (0..vec.len()).step_by(4) {
        result.push(u32::from_be_bytes([
            vec[i],
            vec[i + 1],
            vec[i + 2],
            vec[i + 3],
        ]));
    }

    result
}
