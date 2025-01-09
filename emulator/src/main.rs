use cpu::Processor;
use log::LevelFilter;

pub mod cpu;
pub mod ops;

fn main() {
    simple_logger::SimpleLogger::new()
        .with_colors(true)
        .with_level(LevelFilter::Debug)
        .without_timestamps()
        .init()
        .unwrap();

    // python: convert = lambda x: [y for y in x.to_bytes(4, 'big')]

    #[rustfmt::skip]
    let rom = vec![
        8, 1, 0, 255,  // llo $1,    255
        88, 0, 0, 0,   // nop
        88, 0, 0, 0,   // nop
        88, 0, 0, 0,   // nop
        88, 0, 0, 0,   // nop
        88, 0, 0, 0,   // nop
        36, 32, 0, 0,  // sb  0($0), $1 
        88, 0, 0, 0,   // nop
        88, 0, 0, 0,   // nop
        88, 0, 0, 0,   // nop
        88, 0, 0, 0,   // nop
        88, 0, 0, 0,   // nop
        88, 0, 0, 0,   // nop
    ];

    let mut cpu = Processor::new(rom, 4096, 0);

    for _ in 0..12 {
        cpu.tick().unwrap();
    }

    println!("MEM[0] = {}", cpu.ram[0]);
}
