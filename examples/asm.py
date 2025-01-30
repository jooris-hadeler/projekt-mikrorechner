import sys

OP_ARITHMETIC = 0x0
OP_SET_HIGH = 0x1
OP_SET_LOW = 0x2
OP_LOAD = 0x3
OP_STORE = 0x4
OP_BRANCH = 0x5
OP_JUMP_REGISTER = 0x6
OP_JUMP = 0x7
OP_HALT = 0x3E
OP_NO_OP = 0x3F

REG_ZERO = 0
REG_ONE = 1
REG_2 = 2
REG_3 = 3
REG_4 = 4
REG_5 = 5
REG_6 = 6
REG_7 = 7
REG_8 = 8
REG_9 = 9
REG_10 = 10
REG_11 = 11
REG_12 = 12
REG_13 = 13
REG_14 = 14
REG_15 = 15
REG_16 = 16
REG_17 = 17
REG_18 = 18
REG_19 = 19
REG_20 = 20
REG_21 = 21
REG_22 = 22
REG_23 = 23
REG_24 = 24
REG_25 = 25
REG_26 = 26
REG_27 = 27
REG_28 = 28
REG_29 = 29
REG_BASE_POINTER = 30
REG_STACK_POINTER = 31

def _is_valid_register(reg: int) -> bool:
    return reg >= REG_ZERO and reg <= REG_STACK_POINTER

FUNC_ADD = 0
FUNC_SUB = 1
FUNC_AND = 2
FUNC_OR = 3
FUNC_XOR = 4
FUNC_SHL = 5
FUNC_SAL = 6
FUNC_SHR = 7
FUNC_SAR = 8
FUNC_NOT = 9
FUNC_LTS = 10
FUNC_GTS = 11
FUNC_LTU = 12
FUNC_GTU = 13
FUNC_EQ = 14
FUNC_NE = 15

buffer: list[int] = []


def twos_complement(number, bits=16):
    # Handle negative numbers by adding 2^bits and applying a mask to fit the bit size
    if number < 0:
        return (number + (1 << bits)) & ((1 << bits) - 1)
    # For non-negative numbers, just apply a mask to fit within the specified bit size
    return number & ((1 << bits) - 1)


def current_pc() -> int:
    global buffer
    return len(buffer) - 1


def _r(funct: int, d: int, s: int, t: int):
    global buffer

    assert funct >= FUNC_ADD and funct <= FUNC_NE
    assert _is_valid_register(d) and d != 0
    assert _is_valid_register(s)
    assert _is_valid_register(t)

    instr = s << 21 | t << 16 | d << 11 | funct
    buffer.append(instr)
    

def _i(op: int, s: int, t: int, imm: int):
    assert _is_valid_register(s)
    assert _is_valid_register(t)
    assert imm >= 0 and imm < 2**16

    instr = op << 26 | s << 21 | t << 16 | imm
    buffer.append(instr)


def _j(op: int, addr: int):
    assert 0 <= addr and addr < 2**26
    instr = op << 26 | addr
    buffer.append(instr)

def add(dst: int, op1: int, op2: int):
    _r(FUNC_ADD, dst, op1, op2)

def sub(dst: int, op1: int, op2: int):
    _r(FUNC_SUB, dst, op1, op2)

def and_(dst: int, op1: int, op2: int):
    _r(FUNC_AND, dst, op1, op2)

def or_(dst: int, op1: int, op2: int):
    _r(FUNC_OR, dst, op1, op2)

def xor(dst: int, op1: int, op2: int):
    _r(FUNC_XOR, dst, op1, op2)

def shl(dst: int, op1: int, op2: int):
    _r(FUNC_SHL, dst, op1, op2)

def sal(dst: int, op1: int, op2: int):
    _r(FUNC_SAL, dst, op1, op2)

def shr(dst: int, op1: int, op2: int):
    _r(FUNC_SHR, dst, op1, op2)

def sar(dst: int, op1: int, op2: int):
    _r(FUNC_SAR, dst, op1, op2)

def not_(dst: int, op1: int):
    _r(FUNC_NOT, dst, op1, REG_ZERO)

def lts(dst: int, op1: int, op2: int):
    _r(FUNC_LTS, dst, op1, op2)

def gts(dst: int, op1: int, op2: int):
    _r(FUNC_GTS, dst, op1, op2)

def ltu(dst: int, op1: int, op2: int):
    _r(FUNC_LTU, dst, op1, op2)

def gtu(dst: int, op1: int, op2: int):
    _r(FUNC_GTU, dst, op1, op2)

def eq(dst: int, op1: int, op2: int):
    _r(FUNC_EQ, dst, op1, op2)

def ne(dst: int, op1: int, op2: int):
    _r(FUNC_NE, dst, op1, op2)

def set_high(dst: int, imm: int):
    _i(OP_SET_HIGH, REG_ZERO, dst, imm)

def set_low(dst: int, imm: int):
    _i(OP_SET_LOW, REG_ZERO, dst, imm)

def jump_register(reg: int):
    _i(OP_JUMP_REGISTER, reg, reg, 0)

def jump(relative_offset: int):
    _j(OP_JUMP, twos_complement(relative_offset - 1, bits=26))

def branch(cond: int, relative_offset: int):
    _i(OP_BRANCH, cond, cond, twos_complement(relative_offset - 1, bits=16))

def nop():
    _j(OP_NO_OP, 0)

def halt():
    _j(OP_HALT, 0)

def print_program():
    for instr in buffer:
        print(hex(instr)[2:].rjust(8, '0'))

def save_program(file: str):
    with open(file, 'wb') as fd:
        for instr in buffer:
            byte_data = instr.to_bytes(4, byteorder='big', signed=False)
            fd.write(byte_data)
    