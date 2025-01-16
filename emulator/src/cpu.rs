use std::{fmt::Debug, u32};

use crate::isa::{Function, Instruction, IsaError, OpCode, Register};
use log::{debug, trace};
use thiserror::Error;

#[derive(Debug, Error, Clone, Copy, PartialEq, Eq)]
pub enum ExecutionError {
    #[error("Attempted to read from / write to RAM, but address {0:x} is out of bounds.")]
    RamOutOfBounds(u32),

    #[error("Attempted ro read from ROM, but address {0:x} is out of bounds.")]
    RomOutOfBounds(u32),

    #[error("Attempted to write value to $0 which is forbidden.")]
    InvalidRegisterWrite,

    #[error("Invalid Instruction found in ROM image: {0}")]
    InvalidInstruction(#[from] IsaError),
}

#[derive(Clone, Copy)]
struct IfId {
    instruction_word: u32,
    next_program_counter: u32,
}

impl Debug for IfId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let Self {
            instruction_word,
            next_program_counter,
        } = self;

        write!(f, "npc={next_program_counter}, iw={instruction_word}")
    }
}

#[derive(Clone, Copy)]
struct IdEx {
    next_program_counter: u32,
    op: OpCode,
    funct: Function,
    vs: u32,
    vt: u32,
    rd: Register,
    imm_addr: u32,
}

impl Debug for IdEx {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let Self {
            next_program_counter,
            op,
            funct,
            vs,
            vt,
            rd,
            imm_addr,
        } = self;

        write!(f, "npc={next_program_counter}, op={op:?}, funct={funct:?}, vs={vs}, vt={vt}, rd={rd:?}, imm_addr={imm_addr}")
    }
}

#[derive(Clone, Copy)]
struct ExMem {
    next_program_counter: u32,
    op: OpCode,
    vd: u32,
    vt: u32,
    rd: Register,
    addr: u32,
}

impl Debug for ExMem {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let Self {
            next_program_counter,
            op,
            vd,
            vt,
            rd,
            addr,
        } = self;

        write!(
            f,
            "npc={next_program_counter}, op={op:?}, vd={vd}, vt={vt}, rd={rd:?}, addr={addr}"
        )
    }
}

#[derive(Clone, Copy)]
struct MemWb {
    reg: Register,
    value: u32,
}

impl Debug for MemWb {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let Self { reg, value } = self;

        write!(f, "reg={reg:?}, value={value}")
    }
}

pub struct Processor {
    pub rom: Vec<u8>,
    pub ram: Vec<u8>,
    pub program_counter: u32,
    pub registers: [u32; 32],
    pub should_halt: bool,

    stage_registers: (Option<IfId>, Option<IdEx>, Option<ExMem>, Option<MemWb>),
}

impl Processor {
    pub fn new(rom: Vec<u8>, ram_size: u32, program_counter: u32) -> Self {
        Self {
            rom,
            ram: vec![0; ram_size as usize],
            program_counter,
            registers: [0; 32],
            stage_registers: Default::default(),
            should_halt: false,
        }
    }

    fn store_reg(&mut self, register: Register, value: u32) -> Result<(), ExecutionError> {
        trace!("store_reg(register = {register:?}, value = {value})");
        if register == Register::RZero {
            return Err(ExecutionError::InvalidRegisterWrite);
        }

        self.registers[register.index()] = value;
        Ok(())
    }

    fn load_reg(&self, register: Register) -> u32 {
        trace!("load_reg(register = {register:?})");
        let value = self.registers[register.index()];
        value
    }

    fn read_rom(&self, address: u32) -> Result<u8, ExecutionError> {
        trace!("read_rom(address = {address})");
        self.rom
            .get(address as usize)
            .copied()
            .ok_or(ExecutionError::RomOutOfBounds(address))
    }

    fn read_ram(&self, address: u32) -> Result<u8, ExecutionError> {
        trace!("read_ram(address = {address})");

        self.ram
            .get(address as usize)
            .copied()
            .ok_or(ExecutionError::RamOutOfBounds(address))
    }

    fn write_ram(&mut self, address: u32, value: u8) -> Result<(), ExecutionError> {
        trace!("write_ram(address = {address}, value = {value})");

        let cell = self
            .ram
            .get_mut(address as usize)
            .ok_or(ExecutionError::RamOutOfBounds(address))?;

        *cell = value;

        Ok(())
    }

    pub fn tick(&mut self) -> Result<(), ExecutionError> {
        debug!("BEGIN TICK");

        let (ifid, idex, exmem, memwb) = self.stage_registers;
        debug!("fetch     <- {}", self.program_counter);
        debug!("decode    <- {ifid:?}");
        debug!("execute   <- {idex:?}");
        debug!("memory    <- {exmem:?}");
        debug!("writeback <- {memwb:?}");

        let new_ifid = self.fetch()?;
        let new_idex = self.decode(ifid)?;
        let new_exmem = self.execute(idex)?;
        let new_memwb = self.memory(exmem)?;
        self.write_back(memwb)?;

        debug!("fetch     -> {new_ifid:?}");
        debug!("decode    -> {new_idex:?}");
        debug!("execute   -> {new_exmem:?}");
        debug!("memory    -> {new_memwb:?}");
        debug!("writeback -> None");
        self.stage_registers = (new_ifid, new_idex, new_exmem, new_memwb);
        debug!("END TICK");

        Ok(())
    }

    fn fetch(&mut self) -> Result<Option<IfId>, ExecutionError> {
        let instruction_word = u32::from_be_bytes([
            self.read_rom(self.program_counter + 0)?,
            self.read_rom(self.program_counter + 1)?,
            self.read_rom(self.program_counter + 2)?,
            self.read_rom(self.program_counter + 3)?,
        ]);

        let next_program_counter = self.program_counter + 4;
        self.program_counter = next_program_counter;

        let ifid = Some(IfId {
            instruction_word,
            next_program_counter,
        });

        Ok(ifid)
    }

    fn decode(&mut self, ifid: Option<IfId>) -> Result<Option<IdEx>, ExecutionError> {
        let Some(IfId {
            instruction_word,
            next_program_counter,
        }) = ifid
        else {
            return Ok(None);
        };

        let instruction = Instruction::try_from(instruction_word)?;

        Ok(Some(match instruction {
            Instruction::R(instr) => IdEx {
                next_program_counter,
                op: instr.op,
                funct: instr.funct,
                vs: self.load_reg(instr.rs),
                vt: self.load_reg(instr.rt),
                rd: instr.rd,
                imm_addr: 0,
            },
            Instruction::I(instr) => IdEx {
                next_program_counter,
                op: instr.op,
                funct: Function::Add,
                vs: self.load_reg(instr.rs),
                vt: self.load_reg(instr.rt),
                rd: instr.rt,
                imm_addr: instr.imm as u32,
            },
            Instruction::J(instr) => IdEx {
                next_program_counter,
                op: instr.op,
                funct: Function::Add,
                vs: 0,
                vt: 0,
                rd: Register::RZero,
                imm_addr: instr.addr,
            },
        }))
    }

    fn execute(&mut self, idex: Option<IdEx>) -> Result<Option<ExMem>, ExecutionError> {
        let Some(IdEx {
            next_program_counter,
            op,
            funct,
            vs,
            vt,
            rd,
            imm_addr,
        }) = idex
        else {
            return Ok(None);
        };

        Ok(match op {
            OpCode::ArithmeticLogic => {
                let vd = match funct {
                    Function::Add => vs.wrapping_add(vt),
                    Function::Sub => vs.wrapping_sub(vt),
                    Function::And => vs & vt,
                    Function::Or => vs | vt,
                    Function::Xor => vs ^ vt,
                    Function::Shl => vs << vt,
                    Function::Sal => ((vs as i32) << vt) as u32,
                    Function::Shr => vs >> vt,
                    Function::Sar => ((vs as i32) >> vt) as u32,
                    Function::Not => !vs,
                    Function::LtS => ((vs as i32) < (vt as i32)) as u32,
                    Function::GtS => ((vs as i32) > (vt as i32)) as u32,
                    Function::LtU => (vs < vt) as u32,
                    Function::GtU => (vs > vt) as u32,
                    Function::Eq => (vs == vt) as u32,
                    Function::Ne => (vs != vt) as u32,
                };

                Some(ExMem {
                    next_program_counter,
                    op,
                    vd,
                    vt: 0,
                    rd,
                    addr: 0,
                })
            }
            OpCode::LoadHigh => Some(ExMem {
                next_program_counter,
                op,
                vd: (vt & 0xFFFF) | (imm_addr & 0xFFFF) << 16,
                vt: 0,
                rd,
                addr: 0,
            }),
            OpCode::LoadLow => Some(ExMem {
                next_program_counter,
                op,
                vd: (vt & 0xFFFF0000) | (imm_addr & 0xFFFF),
                vt: 0,
                rd,
                addr: 0,
            }),
            OpCode::LoadByte | OpCode::LoadByteUnsigned => Some(ExMem {
                next_program_counter,
                op,
                vd: vs,
                vt: 0,
                rd,
                addr: imm_addr,
            }),
            OpCode::StoreByte => Some(ExMem {
                next_program_counter,
                op,
                vd: vs,
                vt,
                rd,
                addr: imm_addr,
            }),

            OpCode::Halt => {
                self.should_halt = true;

                Some(ExMem {
                    next_program_counter,
                    op,
                    vd: 0,
                    vt: 0,
                    rd: Register::R10,
                    addr: 0,
                })
            }

            OpCode::Nop => None,

            _ => unimplemented!(),
        })
    }

    fn memory(&mut self, exmem: Option<ExMem>) -> Result<Option<MemWb>, ExecutionError> {
        let Some(ExMem {
            op,
            vd,
            vt,
            rd,
            addr,
            ..
        }) = exmem
        else {
            return Ok(None);
        };

        // Manipulate Program counter here
        let offset_addr = (addr as u16) as i32;

        Ok(match op {
            OpCode::ArithmeticLogic | OpCode::LoadHigh | OpCode::LoadLow => {
                Some(MemWb { reg: rd, value: vd })
            }
            OpCode::LoadByte => {
                let addr = vd.wrapping_add_signed(offset_addr);
                let byte = self.read_ram(addr)? as i8;

                Some(MemWb {
                    reg: rd,
                    value: (byte as i32) as u32,
                })
            }
            OpCode::LoadByteUnsigned => {
                let addr = vd.wrapping_add_signed(offset_addr);
                let byte = self.read_ram(addr)?;

                Some(MemWb {
                    reg: rd,
                    value: byte as u32,
                })
            }
            OpCode::StoreByte => {
                let addr = vt.wrapping_add_signed(offset_addr);
                let value = (vd & 0xFF) as u8;

                self.write_ram(addr, value)?;

                None
            }

            _ => unimplemented!(),
        })
    }

    fn write_back(&mut self, memwb: Option<MemWb>) -> Result<(), ExecutionError> {
        let Some(MemWb { reg, value }) = memwb else {
            return Ok(());
        };

        self.store_reg(reg, value)?;

        Ok(())
    }
}
