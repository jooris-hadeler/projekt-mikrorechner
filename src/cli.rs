use std::path::PathBuf;

use clap::Parser;

#[derive(Debug, Parser)]
pub struct Cli {
    /// The binary image of the ROM.
    pub file: PathBuf,

    /// Enable verbose output.
    #[clap(short, long)]
    pub verbose: bool,

    /// Set the RAM size.
    #[clap(short, long, default_value_t = 4096)]
    pub ram_size: u32,

    /// Set the entry point.
    #[clap(short, long, default_value_t = 0)]
    pub entry: u32,
}
