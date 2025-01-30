use std::path::PathBuf;

use clap::Parser;

#[derive(Debug, Parser)]
pub struct Cli {
    /// The binary image of the ROM.
    pub file: PathBuf,

    /// Enable interactive mode.
    #[clap(short, long)]
    pub interactive: bool,

    /// Set the RAM size.
    #[clap(short, long, default_value_t = 65536)]
    pub ram_size: u32,

    /// Set the entry point.
    #[clap(short, long, default_value_t = 0)]
    pub entry: u32,
}
