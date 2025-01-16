use std::fmt::Display;

use thiserror::Error;

#[derive(Debug, Error, Clone, Copy, PartialEq, Eq)]
pub enum IsaError {
    #[error("invalid register {0} must be in the range of 0..31")]
    InvalidRegister(u32),

    #[error("invalid opcode {0} must be in the range of 0..22")]
    InvalidOpCode(u32),

    #[error("invalid function {0} must be in the range of 0..15")]
    InvalidFunct(u32),
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Register {
    RZero,
    R1,
    R2,
    R3,
    R4,
    R5,
    R6,
    R7,
    R8,
    R9,
    R10,
    R11,
    R12,
    R13,
    R14,
    R15,
    R16,
    R17,
    R18,
    R19,
    R20,
    R21,
    R22,
    R23,
    R24,
    R25,
    R26,
    R27,
    R28,
    R29,
    RBasePointer,
    RStackPointer,
}

impl Register {
    pub fn index(&self) -> usize {
        match self {
            Register::RZero => 0,
            Register::R1 => 1,
            Register::R2 => 2,
            Register::R3 => 3,
            Register::R4 => 4,
            Register::R5 => 5,
            Register::R6 => 6,
            Register::R7 => 7,
            Register::R8 => 8,
            Register::R9 => 9,
            Register::R10 => 10,
            Register::R11 => 11,
            Register::R12 => 12,
            Register::R13 => 13,
            Register::R14 => 14,
            Register::R15 => 15,
            Register::R16 => 16,
            Register::R17 => 17,
            Register::R18 => 18,
            Register::R19 => 19,
            Register::R20 => 20,
            Register::R21 => 21,
            Register::R22 => 22,
            Register::R23 => 23,
            Register::R24 => 24,
            Register::R25 => 25,
            Register::R26 => 26,
            Register::R27 => 27,
            Register::R28 => 28,
            Register::R29 => 29,
            Register::RBasePointer => 30,
            Register::RStackPointer => 31,
        }
    }
}

impl Default for Register {
    fn default() -> Self {
        Register::R1
    }
}

impl TryFrom<u32> for Register {
    type Error = IsaError;

    fn try_from(value: u32) -> Result<Self, Self::Error> {
        use Register::*;

        Ok(match value {
            0 => RZero,
            1 => R1,
            2 => R2,
            3 => R3,
            4 => R4,
            5 => R5,
            6 => R6,
            7 => R7,
            8 => R8,
            9 => R9,
            10 => R10,
            11 => R11,
            12 => R12,
            13 => R13,
            14 => R14,
            15 => R15,
            16 => R16,
            17 => R17,
            18 => R18,
            19 => R19,
            20 => R20,
            21 => R21,
            22 => R22,
            23 => R23,
            24 => R24,
            25 => R25,
            26 => R26,
            27 => R27,
            28 => R28,
            29 => R29,
            30 => RBasePointer,
            31 => RStackPointer,
            x => return Err(IsaError::InvalidRegister(x)),
        })
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Function {
    Add,
    Sub,
    And,
    Or,
    Xor,
    Shl,
    Sal,
    Shr,
    Sar,
    Not,
    LtS,
    GtS,
    LtU,
    GtU,
    Eq,
    Ne,
}

impl Default for Function {
    fn default() -> Self {
        Function::Add
    }
}

impl TryFrom<u32> for Function {
    type Error = IsaError;

    fn try_from(value: u32) -> Result<Self, Self::Error> {
        use Function::*;

        Ok(match value {
            0 => Add,
            1 => Sub,
            2 => And,
            3 => Or,
            4 => Xor,
            5 => Shl,
            6 => Sal,
            7 => Shr,
            8 => Sar,
            9 => Not,
            10 => LtS,
            11 => GtS,
            12 => LtU,
            13 => GtU,
            14 => Eq,
            15 => Ne,
            x => return Err(IsaError::InvalidFunct(x)),
        })
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum OpCode {
    ArithmeticLogic,
    LoadHigh,
    LoadLow,
    LoadByte,
    LoadByteUnsigned,
    LoadHalfWord,
    LoadHalfWordUnsigned,
    LoadWord,
    LoadWordUnsigned,
    StoreByte,
    StoreHalfWord,
    StoreWord,
    Branch,
    JumpRegister,
    Jump,
    Push,
    Pop,
    Call,
    CallR,
    Ret,
    Trap,
    Halt,
    Nop,
}

impl Default for OpCode {
    fn default() -> Self {
        OpCode::Nop
    }
}

impl TryFrom<u32> for OpCode {
    type Error = IsaError;

    fn try_from(value: u32) -> Result<Self, Self::Error> {
        use OpCode::*;

        Ok(match value {
            0 => ArithmeticLogic,
            1 => LoadHigh,
            2 => LoadLow,
            3 => LoadByte,
            4 => LoadByteUnsigned,
            5 => LoadHalfWord,
            6 => LoadHalfWordUnsigned,
            7 => LoadWord,
            8 => LoadWordUnsigned,
            9 => StoreByte,
            10 => StoreHalfWord,
            11 => StoreWord,
            12 => Branch,
            13 => JumpRegister,
            14 => Jump,
            15 => Push,
            16 => Pop,
            17 => Call,
            18 => CallR,
            19 => Ret,
            20 => Trap,
            21 => Halt,
            22 => Nop,
            x => return Err(IsaError::InvalidOpCode(x)),
        })
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Instruction {
    R(RInstruction),
    I(IInstruction),
    J(JInstruction),
}

impl TryFrom<u32> for Instruction {
    type Error = IsaError;

    fn try_from(value: u32) -> Result<Self, Self::Error> {
        let op = OpCode::try_from(value >> 26)?;

        match op {
            OpCode::ArithmeticLogic => {
                let rs = Register::try_from((value >> 21) & 0x1F)?;
                let rt = Register::try_from((value >> 16) & 0x1F)?;
                let rd = Register::try_from((value >> 11) & 0x1F)?;
                let shamt = ((value >> 6) & 0x1F) as u8;
                let funct = Function::try_from(value & 0x3F)?;

                Ok(Instruction::R(RInstruction {
                    op,
                    rs,
                    rt,
                    rd,
                    shamt,
                    funct,
                }))
            }
            OpCode::Jump | OpCode::Call => {
                let addr = value & 0x3FFFFFF;

                Ok(Instruction::J(JInstruction { op, addr }))
            }
            _ => {
                let rs = Register::try_from((value >> 21) & 0x1F)?;
                let rt = Register::try_from((value >> 16) & 0x1F)?;
                let imm = (value & 0xFFFF) as u16;

                Ok(Instruction::I(IInstruction { op, rs, rt, imm }))
            }
        }
    }
}

impl Display for Instruction {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Instruction::R(instr) => {
                write!(
                    f,
                    "{:?} rd={:?}, rs={:?}, rt={:?}",
                    instr.funct, instr.rd, instr.rs, instr.rt
                )
            }
            Instruction::I(instr) => write!(
                f,
                "{:?} rs={:?}, rt={:?}, imm={:?}",
                instr.op, instr.rs, instr.rt, instr.imm
            ),
            Instruction::J(instr) => write!(f, "{:?} addr={:?}", instr.op, instr.addr),
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct RInstruction {
    pub op: OpCode,
    pub rs: Register,
    pub rt: Register,
    pub rd: Register,
    pub shamt: u8,
    pub funct: Function,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct IInstruction {
    pub op: OpCode,
    pub rs: Register,
    pub rt: Register,
    pub imm: u16,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct JInstruction {
    pub op: OpCode,
    pub addr: u32,
}
