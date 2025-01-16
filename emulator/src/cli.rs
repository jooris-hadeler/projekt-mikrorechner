use std::path::PathBuf;

use clap::Parser;

#[derive(Debug, Parser)]
pub struct Cli {
    /// Enable verbose emulator output.
    #[clap(short, long)]
    pub verbose: bool,

    /// Set the size of the Random Access Memory (RAM).
    #[clap(short, long, default_value_t = 8192)]
    pub ram_size: u32,

    /// Set the program counter to start at.
    #[clap(short, long, default_value_t = 0)]
    pub program_counter: u32,

    /// Binary file to run.
    pub file: PathBuf,
}
