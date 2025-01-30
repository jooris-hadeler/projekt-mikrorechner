use std::fmt::Display;

use crate::{
    emulator::{convert_imm16, convert_imm26},
    isa::*,
};

pub const REGISTER_NAMES: [&'static str; 32] = [
    "$zero", "$one", "$2", "$3", "$4", "$5", "$6", "$7", "$8", "$9", "$10", "$11", "$12", "$13",
    "$14", "$15", "$16", "$17", "$18", "$19", "$20", "$21", "$22", "$23", "$24", "$25", "$26",
    "$27", "$28", "$29", "$bp", "$sp",
];

pub const FUNCTION_NAMES: [&'static str; 16] = [
    "add", "sub", "and", "or", "xor", "shl", "sal", "shr", "sar", "not", "lts", "gts", "ltu",
    "gtu", "eq", "ne",
];

impl Display for Instruction {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self.get_op() {
            opcode::OP_ARITHMETIC => write!(
                f,
                "{} {}, {}, {}",
                FUNCTION_NAMES[self.get_funct() as usize],
                REGISTER_NAMES[self.get_rd() as usize],
                REGISTER_NAMES[self.get_rs() as usize],
                REGISTER_NAMES[self.get_rt() as usize]
            ),
            opcode::OP_SET_HIGH => write!(
                f,
                "shi {}, {}",
                REGISTER_NAMES[self.get_rt() as usize],
                self.get_imm16()
            ),
            opcode::OP_SET_LOW => write!(
                f,
                "slo {}, {}",
                REGISTER_NAMES[self.get_rt() as usize],
                self.get_imm16()
            ),
            opcode::OP_LOAD => write!(
                f,
                "ld {}, {}({})",
                REGISTER_NAMES[self.get_rt() as usize],
                convert_imm16(self.get_imm16()),
                REGISTER_NAMES[self.get_rs() as usize]
            ),
            opcode::OP_STORE => write!(
                f,
                "str {}({}), {}",
                convert_imm16(self.get_imm16()),
                REGISTER_NAMES[self.get_rt() as usize],
                REGISTER_NAMES[self.get_rs() as usize]
            ),
            opcode::OP_BRANCH => write!(
                f,
                "br {}, {}",
                REGISTER_NAMES[self.get_rs() as usize],
                convert_imm16(self.get_imm16())
            ),
            opcode::OP_JUMP_REGISTER => write!(f, "jr {}", REGISTER_NAMES[self.get_rs() as usize]),
            opcode::OP_JUMP => write!(f, "jmp {}", convert_imm26(self.get_imm26())),
            opcode::OP_HALT => write!(f, "halt"),
            opcode::OP_NO_OP => write!(f, "nop"),

            _ => unreachable!(),
        }
    }
}
