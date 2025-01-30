use bitfield::bitfield;

bitfield! {
    #[derive(Debug, Clone, Copy)]
    pub struct Instruction(u32);
    pub get_op, set_op: 31, 26;
    pub get_rs, set_rs: 25, 21;
    pub get_rt, set_rt: 20, 16;
    pub get_rd, set_rd: 15, 11;
    pub get_shamt, set_shamt: 10, 5;
    pub get_funct, set_funct: 4, 0;
    pub get_imm16, set_imm16: 15, 0;
    pub get_imm26, set_imm26: 25, 0;
}

pub mod register {
    #![allow(unused)]
    pub const REG_ZERO: u32 = 0;
    pub const REG_ONE: u32 = 1;
    pub const REG_2: u32 = 2;
    pub const REG_3: u32 = 3;
    pub const REG_4: u32 = 4;
    pub const REG_5: u32 = 5;
    pub const REG_6: u32 = 6;
    pub const REG_7: u32 = 7;
    pub const REG_8: u32 = 8;
    pub const REG_9: u32 = 9;
    pub const REG_10: u32 = 10;
    pub const REG_11: u32 = 11;
    pub const REG_12: u32 = 12;
    pub const REG_13: u32 = 13;
    pub const REG_14: u32 = 14;
    pub const REG_15: u32 = 15;
    pub const REG_16: u32 = 16;
    pub const REG_17: u32 = 17;
    pub const REG_18: u32 = 18;
    pub const REG_19: u32 = 19;
    pub const REG_20: u32 = 20;
    pub const REG_21: u32 = 21;
    pub const REG_22: u32 = 22;
    pub const REG_23: u32 = 23;
    pub const REG_24: u32 = 24;
    pub const REG_25: u32 = 25;
    pub const REG_26: u32 = 26;
    pub const REG_27: u32 = 27;
    pub const REG_28: u32 = 28;
    pub const REG_29: u32 = 29;
    pub const REG_BASE_POINTER: u32 = 30;
    pub const REG_STACK_POINTER: u32 = 31;
}

pub mod opcode {
    #![allow(unused)]
    pub const OP_ARITHMETIC: u32 = 0x0;
    pub const OP_SET_HIGH: u32 = 0x1;
    pub const OP_SET_LOW: u32 = 0x2;
    pub const OP_LOAD: u32 = 0x3;
    pub const OP_STORE: u32 = 0x4;
    pub const OP_BRANCH: u32 = 0x5;
    pub const OP_JUMP_REGISTER: u32 = 0x6;
    pub const OP_JUMP: u32 = 0x7;
    pub const OP_HALT: u32 = 0x3E;
    pub const OP_NO_OP: u32 = 0x3F;

    pub const fn uses_format_r(op: u32) -> bool {
        matches!(op, OP_ARITHMETIC)
    }

    pub const fn uses_format_j(op: u32) -> bool {
        matches!(op, OP_JUMP)
    }

    pub const fn uses_format_i(op: u32) -> bool {
        !uses_format_r(op) && !uses_format_j(op)
    }
}

pub mod function {
    #![allow(unused)]
    pub const FUNC_ADD: u32 = 0;
    pub const FUNC_SUB: u32 = 1;
    pub const FUNC_AND: u32 = 2;
    pub const FUNC_OR: u32 = 3;
    pub const FUNC_XOR: u32 = 4;
    pub const FUNC_SHL: u32 = 5;
    pub const FUNC_SAL: u32 = 6;
    pub const FUNC_SHR: u32 = 7;
    pub const FUNC_SAR: u32 = 8;
    pub const FUNC_NOT: u32 = 9;
    pub const FUNC_LTS: u32 = 10;
    pub const FUNC_GTS: u32 = 11;
    pub const FUNC_LTU: u32 = 12;
    pub const FUNC_GTU: u32 = 13;
    pub const FUNC_EQ: u32 = 14;
    pub const FUNC_NE: u32 = 15;
    pub const LAST_FUNCT: u32 = 16;
}
