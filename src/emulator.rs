use log::{debug, info};

use crate::{function, opcode, Instruction};

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
        Self {
            ram: vec![0; ram_size as usize * 4],
            rom,
            registers: [0; 32],
            should_halt: false,
            state: (entry, None, None, None, None),
        }
    }

    pub const fn should_halt(&self) -> bool {
        self.should_halt
    }

    pub fn tick(&mut self) {
        debug!("Tick: {:?}", self.state);

        let (program_counter, decode_input, execute_input, memory_input, writeback_input) =
            self.state;

        info!("Current PC: {:x}", program_counter);
        info!("Registers: {:?}", self.registers);

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

        debug!(
            "decoded at {:x} op={}, rs={}, rt={}, rd={}, funct={}, imm={}, addr={}",
            next_program_counter.saturating_sub(1),
            op,
            instruction.get_rs(),
            instruction.get_rt(),
            instruction.get_rd(),
            instruction.get_funct(),
            instruction.get_imm16(),
            instruction.get_imm26()
        );

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
                info!("jumping by {offset} to {new_pc:x}");
                (None, Some(new_pc))
            }
            opcode::OP_JUMP_REGISTER => (None, Some(next_program_counter)),
            opcode::OP_BRANCH => {
                if value != 0 {
                    let offset = convert_imm16(addr);
                    debug!(
                        "branched npc = {:x}",
                        next_program_counter.wrapping_add_signed(offset)
                    );
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

fn convert_imm26(imm26: u32) -> i32 {
    ((imm26 << 6) as i32) >> 6
}

fn convert_imm16(imm16: u32) -> i32 {
    imm16 as u16 as i16 as i32
}
