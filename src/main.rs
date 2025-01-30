use std::{
    fs,
    io::{stdin, stdout, Write},
    process::exit,
};

use clap::Parser;
use cli::Cli;
use emulator::Emulator;
use isa::*;
use yansi::Paint;

mod asm;
mod cli;
mod emulator;
mod isa;

fn main() {
    let args = Cli::parse();

    let Ok(rom) = fs::read(&args.file) else {
        eprintln!("{} failed to load rom image.", "error:".bright_red());
        exit(-1);
    };

    let rom_converted = convert_to_word_vec(rom);

    let mut emulator = Emulator::new(rom_converted, args.ram_size, args.entry);

    if args.interactive {
        println!("Interactive mode type `help` for more information.");

        loop {
            print!("cmd > ");
            stdout().flush().unwrap();

            let mut buf = String::new();
            stdin().read_line(&mut buf).unwrap();

            let args: Vec<_> = buf.trim().split(" ").collect();
            if args.is_empty() {
                continue;
            }

            match args[0] {
                "help" => {
                    println!("run      > Run the program until the program finished or we reached a break point.");
                    println!(
                        "continue > Continue execution until we halt or we reach a break point."
                    );
                    println!("addbp    > Add a breakpoint.");
                    println!("rmbp     > Remove a breakpoint.");
                    println!("step     > Cycle the emulator once.");
                    println!("dump     > Dump the values of the registers.");
                    println!("quit     > Quit the program.");
                }
                "run" => {
                    while !emulator.should_halt() && !emulator.has_reached_break_point() {
                        emulator.tick();
                    }
                }
                "continue" => {
                    emulator.tick();

                    while !emulator.should_halt() && !emulator.has_reached_break_point() {
                        emulator.tick();
                    }

                    emulator.print_instructions();
                }
                "addbp" => {
                    if args.len() != 2 {
                        println!("usage: addbp <addr>");
                        continue;
                    }

                    let Ok(addr) = u32::from_str_radix(args[1], 16) else {
                        println!("addr is not a valid hexadecimal number");
                        continue;
                    };

                    emulator.add_breakpoint(addr);
                }
                "rmbp" => {
                    if args.len() != 2 {
                        println!("usage: rmbp <addr>");
                        continue;
                    }

                    let Ok(addr) = u32::from_str_radix(args[1], 16) else {
                        println!("addr is not a valid hexadecimal number");
                        continue;
                    };

                    emulator.remove_breakpoint(addr);
                }
                "step" => {
                    emulator.tick();
                    emulator.print_instructions();
                }
                "dump" => emulator.print_registers(),
                "quit" => break,
                _ => println!("invalid command: {}", buf),
            }
        }
    } else {
        while !emulator.should_halt() {
            emulator.tick();
        }

        emulator.print_registers();
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
