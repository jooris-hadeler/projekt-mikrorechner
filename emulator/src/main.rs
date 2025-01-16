use std::{fs, process::exit};

use clap::Parser;
use cli::Cli;
use cpu::Processor;
use log::{error, info, LevelFilter};

pub mod cli;
pub mod cpu;
pub mod isa;

fn main() {
    let Cli {
        verbose,
        ram_size,
        file,
        program_counter,
    } = cli::Cli::parse();

    simple_logger::SimpleLogger::new()
        .with_colors(true)
        .with_level(if verbose {
            LevelFilter::Debug
        } else {
            LevelFilter::Info
        })
        .without_timestamps()
        .init()
        .unwrap();

    // python: convert = lambda x: [y for y in x.to_bytes(4, 'big')]

    let Ok(rom) = fs::read(&file) else {
        error!("Failed to load ROM image.");
        exit(-1);
    };

    info!("Set RAM size to {} bytes.", ram_size);
    info!("Successfully loaded ROM image of size {} bytes.", rom.len());

    let mut index = 0;
    let mut emulator = Processor::new(rom, ram_size, program_counter);

    while !emulator.should_halt {
        if let Err(err) = emulator.tick() {
            error!("{err}");
            break;
        };

        index += 1;
    }

    info!("Emulator ran for {} cycles, before halting.", index);

    println!("MEM[0] = {}", emulator.ram[0]);
}
