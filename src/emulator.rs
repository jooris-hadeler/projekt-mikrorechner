use std::collections::HashSet;

use itertools::Itertools;

use crate::{
    asm::REGISTER_NAMES,
    function,
    isa::register::{REG_ONE, REG_STACK_POINTER},
    opcode, Instruction,
};

macro_rules! int_to_bool {
    ($cond:expr) => {
        if $cond {
            1
        } else {
            0
        }
    };
}

#[derive(Debug, Clone, Copy)]
struct DecodeParams {
    instruction: Instruction,
    next_program_counter: u32,
}

#[derive(Debug, Clone, Copy)]
struct ExecuteParams {
    op: u32,
    operand1: u32,
    operand2: u32,
    dest: u32,
    imm_funct: u32,
    next_program_counter: u32,
}

#[derive(Debug, Clone, Copy)]
struct MemoryParams {
    op: u32,
    value: u32,
    addr: u32,
    dest: u32,
    next_program_counter: u32,
}

#[derive(Debug, Clone, Copy)]
struct WriteBackParams {
    register: u32,
    value: u32,
}

pub struct Emulator {
    ram: Vec<u32>,
    rom: Vec<u32>,
    registers: [u32; 32],
    should_halt: bool,
    stage_instructions: [Option<(u32, Instruction)>; 5],
    breakpoints: HashSet<u32>,

    state: (
        u32,
        Option<DecodeParams>,
        Option<ExecuteParams>,
        Option<MemoryParams>,
        Option<WriteBackParams>,
    ),
}

impl Emulator {
    pub fn new(rom: Vec<u32>, ram_size: u32, entry: u32) -> Self {
        let mut registers = [0; 32];
        registers[REG_ONE as usize] = 1;
        registers[REG_STACK_POINTER as usize] = ram_size - 1;

        Self {
            ram: vec![0; ram_size as usize * 4],
            rom,
            registers,
            should_halt: false,
            state: (entry, None, None, None, None),
            stage_instructions: [None; 5],
            breakpoints: HashSet::new(),
        }
    }

    pub fn add_breakpoint(&mut self, addr: u32) {
        self.breakpoints.insert(addr);
    }

    pub fn remove_breakpoint(&mut self, addr: u32) {
        self.breakpoints.remove(&addr);
    }

    pub fn has_reached_break_point(&self) -> bool {
        self.stage_instructions[0].is_some_and(|(addr, _)| self.breakpoints.contains(&addr))
    }

    pub const fn should_halt(&self) -> bool {
        self.should_halt
    }

    pub fn print_instructions(&self) {
        println!();
        for (name, stage) in [" IF", " ID", " EX", "MEM", " WB"]
            .iter()
            .zip(self.stage_instructions.iter())
            .rev()
        {
            let Some((addr, instr)) = stage else {
                continue;
            };

            println!("{} => 0x{:08x}: {}", name, addr, instr);
        }
        println!();
    }

    pub fn print_registers(&self) {
        println!();
        for chunk in &REGISTER_NAMES.iter().enumerate().chunks(4) {
            for (index, name) in chunk {
                print!("{:>5}: 0x{:08x}  ", name, self.registers[index]);
            }

            println!();
        }
    }

    pub fn tick(&mut self) {
        let (program_counter, decode_input, execute_input, memory_input, writeback_input) =
            self.state;

        let (new_decode_input, next_program_counter) = self.fetch(program_counter);
        let new_execute_input = self.decode(decode_input);
        let new_memory_input = self.execute(execute_input);
        let (new_write_back_input, branched_program_counter) = self.memory(memory_input);
        self.write_back(writeback_input);

        let new_fetch_input = branched_program_counter.unwrap_or(next_program_counter);
        self.state = (
            new_fetch_input,
            new_decode_input,
            new_execute_input,
            new_memory_input,
            new_write_back_input,
        );
    }

    fn fetch(&mut self, program_counter: u32) -> (Option<DecodeParams>, u32) {
        let instruction = Instruction(self.load_rom_word(program_counter));
        let next_program_counter = program_counter + 1;

        let [a, b, c, d, _] = self.stage_instructions;
        self.stage_instructions = [Some((program_counter, instruction)), a, b, c, d];

        (
            Some(DecodeParams {
                instruction,
                next_program_counter,
            }),
            next_program_counter,
        )
    }

    fn decode(&mut self, input: Option<DecodeParams>) -> Option<ExecuteParams> {
        let Some(DecodeParams {
            instruction,
            next_program_counter,
        }) = input
        else {
            return None;
        };

        let op = instruction.get_op();

        match op {
            // Instructions with R format
            op if opcode::uses_format_r(op) => Some(ExecuteParams {
                op,
                operand1: self.load_register(instruction.get_rs()),
                operand2: self.load_register(instruction.get_rt()),
                dest: instruction.get_rd(),
                imm_funct: instruction.get_funct(),
                next_program_counter,
            }),

            // Instructions with J format
            op if opcode::uses_format_j(op) => Some(ExecuteParams {
                op,
                operand1: 0,
                operand2: 0,
                dest: 0,
                imm_funct: instruction.get_imm26(),
                next_program_counter,
            }),

            // Instructions with I format
            op if opcode::uses_format_i(op) => Some(ExecuteParams {
                op,
                operand1: self.load_register(instruction.get_rs()),
                operand2: self.load_register(instruction.get_rt()),
                dest: instruction.get_rt(),
                imm_funct: instruction.get_imm16(),
                next_program_counter,
            }),

            op => unimplemented!("unknown op code: {op}"),
        }
    }

    fn execute(&mut self, input: Option<ExecuteParams>) -> Option<MemoryParams> {
        let Some(ExecuteParams {
            op,
            operand1,
            operand2,
            dest,
            imm_funct,
            next_program_counter,
        }) = input
        else {
            return None;
        };

        match op {
            opcode::OP_ARITHMETIC => {
                let value = match imm_funct {
                    function::FUNC_ADD => operand1.wrapping_add(operand2),
                    function::FUNC_SUB => operand1.wrapping_sub(operand2),
                    function::FUNC_AND => operand1 & operand2,
                    function::FUNC_OR => operand1 | operand2,
                    function::FUNC_XOR => operand1 ^ operand2,
                    function::FUNC_SHL => operand1 << operand2,
                    function::FUNC_SAL => ((operand1 as i32) << operand2) as u32,
                    function::FUNC_SHR => operand1 >> operand2,
                    function::FUNC_SAR => ((operand1 as i32) >> operand2) as u32,
                    function::FUNC_NOT => !operand1,
                    function::FUNC_LTS => int_to_bool!((operand1 as i32) < (operand2 as i32)),
                    function::FUNC_GTS => int_to_bool!((operand1 as i32) > (operand2 as i32)),
                    function::FUNC_LTU => int_to_bool!(operand1 < operand2),
                    function::FUNC_GTU => int_to_bool!(operand1 > operand2),
                    function::FUNC_EQ => int_to_bool!(operand1 == operand2),
                    function::FUNC_NE => int_to_bool!(operand1 != operand2),
                    function::LAST_FUNCT.. => panic!("invalid function"),
                };

                Some(MemoryParams {
                    op,
                    value,
                    dest,
                    addr: 0,
                    next_program_counter,
                })
            }
            opcode::OP_SET_HIGH => Some(MemoryParams {
                op,
                value: (operand2 & 0xFFFF) | ((imm_funct & 0xFFFF) << 16),
                dest,
                addr: 0,
                next_program_counter,
            }),
            opcode::OP_SET_LOW => Some(MemoryParams {
                op,
                value: (operand2 & 0xFFFF0000) | (imm_funct & 0xFFFF),
                dest,
                addr: 0,
                next_program_counter,
            }),
            opcode::OP_LOAD => Some(MemoryParams {
                op,
                value: 0,
                addr: operand1.wrapping_add_signed(((imm_funct as u16) as i16) as i32),
                dest,
                next_program_counter,
            }),
            opcode::OP_STORE => Some(MemoryParams {
                op,
                value: operand1,
                addr: operand2.wrapping_add_signed(((imm_funct as u16) as i16) as i32),
                dest,
                next_program_counter,
            }),
            opcode::OP_BRANCH | opcode::OP_JUMP => Some(MemoryParams {
                op,
                value: operand1,
                addr: imm_funct,
                dest: 0,
                next_program_counter,
            }),
            opcode::OP_JUMP_REGISTER => Some(MemoryParams {
                op,
                value: 0,
                addr: 0,
                dest: 0,
                next_program_counter: operand1,
            }),
            opcode::OP_HALT => Some(MemoryParams {
                op,
                value: 0,
                addr: 0,
                dest,
                next_program_counter,
            }),
            opcode::OP_NO_OP => None,

            _ => unimplemented!("{op} is not a valid opcode"),
        }
    }

    fn memory(&mut self, input: Option<MemoryParams>) -> (Option<WriteBackParams>, Option<u32>) {
        let Some(MemoryParams {
            op,
            value,
            dest,
            addr,
            next_program_counter,
        }) = input
        else {
            return (None, None);
        };

        match op {
            opcode::OP_ARITHMETIC | opcode::OP_SET_HIGH | opcode::OP_SET_LOW => (
                Some(WriteBackParams {
                    register: dest,
                    value,
                }),
                None,
            ),
            opcode::OP_LOAD => (
                Some(WriteBackParams {
                    register: dest,
                    value: self.load_ram_word(addr),
                }),
                None,
            ),
            opcode::OP_STORE => {
                self.store_ram_word(addr, value);
                (None, None)
            }
            opcode::OP_JUMP => {
                let offset = convert_imm26(addr);
                let new_pc = next_program_counter.wrapping_add_signed(offset);
                (None, Some(new_pc))
            }
            opcode::OP_JUMP_REGISTER => (None, Some(next_program_counter)),
            opcode::OP_BRANCH => {
                if value != 0 {
                    let offset = convert_imm16(addr);
                    (None, Some(next_program_counter.wrapping_add_signed(offset)))
                } else {
                    (None, None)
                }
            }
            opcode::OP_HALT => {
                self.should_halt = true;
                (None, None)
            }
            opcode::OP_NO_OP => (None, None),

            _ => unimplemented!("{op} is not a valid opcode"),
        }
    }

    fn write_back(&mut self, input: Option<WriteBackParams>) {
        let Some(WriteBackParams { register, value }) = input else {
            return;
        };

        self.store_register(register, value);
    }

    fn load_ram_word(&self, addr: u32) -> u32 {
        load_word(&self.ram, addr)
    }

    fn store_ram_word(&mut self, addr: u32, value: u32) {
        store_word(&mut self.ram, addr, value);
    }

    fn load_rom_word(&self, addr: u32) -> u32 {
        load_word(&self.rom, addr)
    }

    fn load_register(&self, index: u32) -> u32 {
        assert!(index < 32, "tried reading from invalid register");

        self.registers[index as usize]
    }

    fn store_register(&mut self, index: u32, value: u32) {
        assert!(index < 32, "tried writing to invalid register");
        assert_ne!(index, 0, "tried writing to REG_ZERO");
        assert_ne!(index, 1, "tried writing to REG_ONE");

        self.registers[index as usize] = value;
    }
}

fn load_word(slice: &[u32], addr: u32) -> u32 {
    let addr = addr as usize;

    match slice.get(addr) {
        Some(&word) => word,
        None => panic!(
            "tried reading word at 0x{:x}, which is out of bounds for memory of size 0x{:x}",
            addr,
            slice.len()
        ),
    }
}

fn store_word(slice: &mut [u32], addr: u32, value: u32) {
    let addr = addr as usize;

    match slice.get_mut(addr) {
        Some(word) => *word = value,
        None => panic!(
            "tried writing word at 0x{:x}, which is out of bounds for memory of size 0x{:x}",
            addr,
            slice.len()
        ),
    }
}

pub fn convert_imm26(imm26: u32) -> i32 {
    ((imm26 << 6) as i32) >> 6
}

pub fn convert_imm16(imm16: u32) -> i32 {
    imm16 as u16 as i16 as i32
}
