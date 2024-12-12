#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum OpCode {
    /// No operation.
    NoOp,

    /// Add the values of two registers (signed)
    Add,
    /// Add the values of two registers (unsigned)
    AddU,
    /// Add an immediate to the value of a register (signed)
    AddI,
    /// Add an immediate to the value of a register (unsigned)
    AddIU,
    /// Negate the value of a regsiter.
    Neg,
    /// And the values of two registers
    And,
    /// And the value of a register by an immediate
    AndI,
    /// Or the values of two registers
    Or,
    /// Or the value of a register with an immediate
    OrI,
    /// Logically shift the value of a register to the
    /// left by the value of another register
    Shl,
    /// Logically shift the value of a register to the
    /// left by an immediate value
    ShlI,
    /// Arithmetically shift the value of a regsiter to the
    /// left by the value of another register
    Sal,
    /// Arithmetically shift the value of a register to the
    /// left by an immediate value
    SalI,
    /// Logically shift the value of a register to the
    /// right by the value of another register
    Shr,
    /// Logically shift the value of a register to the
    /// right by an immediate value
    ShrI,
    /// Arithmetically shift the value of a register to the
    /// right by the value of another register
    Sar,
    /// Arithmetically shift the value of a register to the
    /// right by an immediate value
    SarI,
    /// Bitwise not a register.
    Not,

    /// Non destructively load the high half-word of the register from an address.
    Lhi,
    /// Non destructively load the low half-word of the register from an address.
    Llo,

    /// Signed less than comparision between two registers.
    Slt,
    /// Signed less than comparision between a register and an immediate value.
    SltI,
    /// Signed greater than comparision between two registers.
    Sgt,
    /// Signed greater than comparision between a register and an immediate value.
    SgtI,
    /// Unsigned less than comparision between two registers.
    Ult,
    /// Unsigned less than comparision between a register and an immediate value.
    UltI,
    /// Unsigned greater than comparision between two registers.
    Ugt,
    /// Unsigned greater than comparision between a register and an immediate value.
    UgtI,

    /// Load a byte from memory (sign extend)
    Lb,
    /// Load a half word from memory (sign extend)
    Lh,
    /// Load a word from memory (sign extend)
    Lw,
    /// Load a byte from memory (zero extend)
    LbU,
    /// Load a half word from memory (zero extend)
    LhU,
    /// Load a word from memory (zero extend)
    LwU,

    /// Store byte in memory.
    Sb,
    /// Store half word in memory.
    Sh,
    /// Store word in memory.
    Sw,

    /// Branch to a given address if register is non zero.
    Br,
    /// Jump to te address in a register
    Jr,
    /// Jump relatively by an offset from the current location.
    Jmp,

    /// Push a register onto the stack.
    Push,
    /// Pop a register from the stack.
    Pop,
    /// Call a subroutine
    Call,
    /// Return from a soubroutine
    Ret,

    /// Trap
    Trap,
    /// Halt
    Halt,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct Instruction {
    pub op_code: OpCode,
    pub arguments: InstructionArguments,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum InstructionArguments {
    Register {
        register_s: RegisterId,
        register_t: RegisterId,
        register_d: RegisterId,
        shift_amount: u8,
        function: u8,
    },
    Immediate {
        register_s: RegisterId,
        register_t: RegisterId,
        immediate: u16,
    },
    Jump {
        address: u32,
    },
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum RegisterId {
    Zero,
    Reg1,
    Reg2,
    Reg3,
    Reg4,
    Reg5,
    Reg6,
    Reg7,
    Reg8,
    Reg9,
    Reg10,
    Reg11,
    Reg12,
    Reg13,
    Reg14,
    Reg15,
    Reg16,
    Reg17,
    Reg18,
    Reg19,
    Reg20,
    Reg21,
    Reg22,
    Reg23,
    Reg24,
    Reg25,
    Reg26,
    Reg27,
    Reg28,
    Reg29,
    BasePointer,
    StackPointer,
}

impl From<RegisterId> for usize {
    fn from(value: RegisterId) -> Self {
        match value {
            RegisterId::Zero => 0,
            RegisterId::Reg1 => 1,
            RegisterId::Reg2 => 2,
            RegisterId::Reg3 => 3,
            RegisterId::Reg4 => 4,
            RegisterId::Reg5 => 5,
            RegisterId::Reg6 => 6,
            RegisterId::Reg7 => 7,
            RegisterId::Reg8 => 8,
            RegisterId::Reg9 => 9,
            RegisterId::Reg10 => 10,
            RegisterId::Reg11 => 11,
            RegisterId::Reg12 => 12,
            RegisterId::Reg13 => 13,
            RegisterId::Reg14 => 14,
            RegisterId::Reg15 => 15,
            RegisterId::Reg16 => 16,
            RegisterId::Reg17 => 17,
            RegisterId::Reg18 => 18,
            RegisterId::Reg19 => 19,
            RegisterId::Reg20 => 20,
            RegisterId::Reg21 => 21,
            RegisterId::Reg22 => 22,
            RegisterId::Reg23 => 23,
            RegisterId::Reg24 => 24,
            RegisterId::Reg25 => 25,
            RegisterId::Reg26 => 26,
            RegisterId::Reg27 => 27,
            RegisterId::Reg28 => 28,
            RegisterId::Reg29 => 29,
            RegisterId::BasePointer => 30,
            RegisterId::StackPointer => 31,
        }
    }
}

impl TryFrom<usize> for RegisterId {
    type Error = &'static str;

    fn try_from(value: usize) -> Result<RegisterId, Self::Error> {
        Ok(match value {
            0 => RegisterId::Zero,
            1 => RegisterId::Reg1,
            2 => RegisterId::Reg2,
            3 => RegisterId::Reg3,
            4 => RegisterId::Reg4,
            5 => RegisterId::Reg5,
            6 => RegisterId::Reg6,
            7 => RegisterId::Reg7,
            8 => RegisterId::Reg8,
            9 => RegisterId::Reg9,
            10 => RegisterId::Reg10,
            11 => RegisterId::Reg11,
            12 => RegisterId::Reg12,
            13 => RegisterId::Reg13,
            14 => RegisterId::Reg14,
            15 => RegisterId::Reg15,
            16 => RegisterId::Reg16,
            17 => RegisterId::Reg17,
            18 => RegisterId::Reg18,
            19 => RegisterId::Reg19,
            20 => RegisterId::Reg20,
            21 => RegisterId::Reg21,
            22 => RegisterId::Reg22,
            23 => RegisterId::Reg23,
            24 => RegisterId::Reg24,
            25 => RegisterId::Reg25,
            26 => RegisterId::Reg26,
            27 => RegisterId::Reg27,
            28 => RegisterId::Reg28,
            29 => RegisterId::Reg29,
            30 => RegisterId::BasePointer,
            31 => RegisterId::StackPointer,
            32.. => return Err("invalid register id, expected value in interval [0,31]"),
        })
    }
}
