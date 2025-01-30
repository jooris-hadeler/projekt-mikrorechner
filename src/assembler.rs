use std::{fs, path::PathBuf, process::exit};

use clap::Parser;
use isa::{function, opcode, register, Instruction};
use phf::phf_map;
use yansi::Paint;

mod isa;

const MNEMONIC_MAP: phf::Map<&'static str, (u32, Option<u32>)> = phf_map! {
    "add" => (opcode::OP_ARITHMETIC, Some(function::FUNC_ADD)),
    "sub" => (opcode::OP_ARITHMETIC, Some(function::FUNC_SUB)),
    "and" => (opcode::OP_ARITHMETIC, Some(function::FUNC_AND)),
    "or" => (opcode::OP_ARITHMETIC, Some(function::FUNC_OR)),
    "xor" => (opcode::OP_ARITHMETIC, Some(function::FUNC_XOR)),
    "shl" => (opcode::OP_ARITHMETIC, Some(function::FUNC_SHL)),
    "sal" => (opcode::OP_ARITHMETIC, Some(function::FUNC_SAL)),
    "shr" => (opcode::OP_ARITHMETIC, Some(function::FUNC_SHR)),
    "sar" => (opcode::OP_ARITHMETIC, Some(function::FUNC_SAR)),
    "not" => (opcode::OP_ARITHMETIC, Some(function::FUNC_NOT)),
    "clts" => (opcode::OP_ARITHMETIC, Some(function::FUNC_LTS)),
    "cgts" => (opcode::OP_ARITHMETIC, Some(function::FUNC_GTS)),
    "cltu" => (opcode::OP_ARITHMETIC, Some(function::FUNC_LTU)),
    "cgtu" => (opcode::OP_ARITHMETIC, Some(function::FUNC_GTU)),
    "ceq" => (opcode::OP_ARITHMETIC, Some(function::FUNC_EQ)),
    "cne" => (opcode::OP_ARITHMETIC, Some(function::FUNC_NE)),

    "shi" => (opcode::OP_SET_HIGH, None),
    "slo" => (opcode::OP_SET_LOW, None),
    "load" => (opcode::OP_LOAD, None),
    "store" => (opcode::OP_STORE, None),
    "br" => (opcode::OP_BRANCH, None),
    "jump" => (opcode::OP_JUMP, None),
    "jr" => (opcode::OP_JUMP_REGISTER, None),
    "nop" => (opcode::OP_NO_OP, None)
};

const REGISTER_MAP: phf::Map<&'static str, u32> = phf_map! {
    "$z" => register::REG_ZERO,
    "$1" => register::REG_1,
    "$2" => register::REG_2,
    "$3" => register::REG_3,
    "$4" => register::REG_4,
    "$5" => register::REG_5,
    "$6" => register::REG_6,
    "$7" => register::REG_7,
    "$8" => register::REG_8,
    "$9" => register::REG_9,
    "$10" => register::REG_10,
    "$11" => register::REG_11,
    "$12" => register::REG_12,
    "$13" => register::REG_13,
    "$14" => register::REG_14,
    "$15" => register::REG_15,
    "$16" => register::REG_16,
    "$17" => register::REG_17,
    "$18" => register::REG_18,
    "$19" => register::REG_19,
    "$20" => register::REG_20,
    "$21" => register::REG_21,
    "$22" => register::REG_22,
    "$23" => register::REG_23,
    "$24" => register::REG_24,
    "$25" => register::REG_25,
    "$26" => register::REG_26,
    "$27" => register::REG_27,
    "$28" => register::REG_28,
    "$29" => register::REG_29,
    "$bp" => register::REG_BASE_POINTER,
    "$sp" => register::REG_STACK_POINTER,
};

#[derive(Debug, Parser)]
struct Cli {
    /// The file to assemble.
    pub file: PathBuf,

    /// The path of the output file.
    #[clap(default_value = "rom.bin")]
    pub output: PathBuf,
}

fn main() {
    let args = Cli::parse();

    let Ok(content) = fs::read_to_string(&args.file) else {
        eprintln!("{} failed to read input file.", "error:".bright_red());
        exit(-1);
    };

    let mut output = Vec::new();
    for line in content.lines() {
        if line.is_empty() {
            continue;
        }

        let line = line.trim();

        let Some((mnemonic, rest)) = line.split_once(" ") else {
            eprintln!("{} invalid line `{}`", "error".bright_red(), line);
            exit(-2);
        };

        let Some((op, func)) = MNEMONIC_MAP.get(mnemonic).copied() else {
            eprintln!(
                "{} invalid instruction `{}`",
                "error".bright_red(),
                mnemonic
            );
            exit(-3);
        };

        let mut instr = Instruction(0);
        instr.set_op(op);

        if opcode::uses_format_r(op) {
            let (rd, rest) = rest.split_once(", ").expect("failed to parse line");
            let (rs, rt) = rest.split_once(", ").expect("failed to parse line");

            let rd = REGISTER_MAP
                .get(rd.trim())
                .copied()
                .expect("invalid register");

            let rs = REGISTER_MAP
                .get(rs.trim())
                .copied()
                .expect("invalid register");

            let rt = REGISTER_MAP
                .get(rt.trim())
                .copied()
                .expect("invalid register");

            instr.set_rd(rd);
            instr.set_rs(rs);
            instr.set_rt(rt);
            instr.set_funct(func.expect("failed to fetch function"));
        } else if opcode::uses_format_j(op) {
            let addr = rest.trim().parse::<u32>().expect("failed to parse address");

            instr.set_imm26(addr);
        } else {
            let (rs, rest) = rest.split_once(", ").expect("failed to parse line");
            let (rt, imm) = rest.split_once(", ").expect("failed to parse line");

            let rs = REGISTER_MAP
                .get(rs.trim())
                .copied()
                .expect("invalid register");

            let rt = REGISTER_MAP
                .get(rt.trim())
                .copied()
                .expect("invalid register");

            let imm = imm.parse::<i16>().expect("failed to parse line");

            instr.set_rs(rs);
            instr.set_rt(rt);
            instr.set_imm16((imm as u16) as u32);
        }

        output.extend(instr.0.to_be_bytes());
    }

    let Ok(_) = fs::write(&args.output, output) else {
        eprintln!("{} failed to write binary image", "error:".bright_red());
        exit(-1);
    };
}
