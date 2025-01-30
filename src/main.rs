use std::{fs, process::exit};

use clap::Parser;
use cli::Cli;
use emulator::Emulator;
use isa::*;
use log::LevelFilter;
use yansi::Paint;

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
            LevelFilter::Info
        })
        .without_timestamps()
        .init()
        .expect("failed to init logger");

    let Ok(rom) = fs::read(&args.file) else {
        eprintln!("{} failed to load rom image.", "error:".bright_red());
        exit(-1);
    };

    let mut emulator = Emulator::new(rom, args.ram_size, args.entry);
    while !emulator.should_halt() {
        emulator.tick();
    }
}
