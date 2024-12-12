use std::io::{self, stdout};

use isa::{Instruction, RegisterId};

pub mod isa;

#[derive(Debug, Clone, Default)]
pub struct RegisterBank {
    registers: [u32; 32],
}

impl RegisterBank {
    const REGISTER_NAMES: [&'static str; 32] = [
        "$z", "$1", "$2", "$3", "$4", "$5", "$6", "$7", "$8", "$9", "$10", "$11", "$12", "$13",
        "$14", "$15", "$16", "$17", "$18", "$19", "$20", "$21", "$22", "$23", "$24", "$25", "$26",
        "$27", "$28", "$29", "$bp", "$sp",
    ];

    pub fn fetch(&self, id: RegisterId) -> u32 {
        if id == RegisterId::Zero {
            return 0;
        }

        let index: usize = id.into();
        self.registers[index]
    }

    pub fn store(&mut self, id: RegisterId, value: u32) {
        if id == RegisterId::Zero {
            return;
        }

        let index: usize = id.into();
        self.registers[index] = value;
    }

    pub fn dump(&self, f: &mut dyn io::Write) -> io::Result<()> {
        writeln!(f, "============== Register Bank ==============")?;

        for idx in 0..32 {
            write!(
                f,
                " {: >3}: {:0>4X} ",
                Self::REGISTER_NAMES[idx],
                self.registers[idx]
            )?;

            if idx % 4 == 3 {
                writeln!(f)?;
            }
        }

        Ok(())
    }
}

pub struct Memory {
    memory: Box<[u8]>,
}

impl Memory {
    pub fn new(mut data: Vec<u8>, size: u32) -> Self {
        while data.len() < size as usize {
            data.push(0);
        }

        Self {
            memory: data.into_boxed_slice(),
        }
    }

    pub fn new_empty(size: u32) -> Self {
        Self {
            memory: vec![0; size as usize].into_boxed_slice(),
        }
    }

    pub const fn size(&self) -> u32 {
        self.memory.len() as u32
    }

    pub fn fetch_byte(&self, address: usize) -> u8 {
        self.memory
            .get(address)
            .copied()
            .expect("tried to read memory out of bounds")
    }

    pub fn fetch_half_word(&self, address: usize) -> u16 {
        u16::from_be_bytes([self.fetch_byte(address), self.fetch_byte(address + 1)])
    }

    pub fn fetch_word(&self, address: usize) -> u32 {
        u32::from_be_bytes([
            self.fetch_byte(address),
            self.fetch_byte(address + 1),
            self.fetch_byte(address + 2),
            self.fetch_byte(address + 3),
        ])
    }

    pub fn store_byte(&mut self, address: usize, value: u8) {
        self.memory[address] = value;
    }

    pub fn store_half_word(&mut self, address: usize, value: u16) {
        for (offset, byte) in value.to_be_bytes().into_iter().enumerate() {
            self.store_byte(address + offset, byte);
        }
    }

    pub fn store_word(&mut self, address: usize, value: u32) {
        for (offset, byte) in value.to_be_bytes().into_iter().enumerate() {
            self.store_byte(address + offset, byte);
        }
    }
}

pub struct Processor {
    pub program_memory: Memory,
    pub data_memory: Memory,
    pub register_bank: RegisterBank,
    pub program_counter: u32,

    instruction: Option<Instruction>,
}

impl Processor {
    pub fn new(program_memory: Memory, data_memory: Memory, entry_point: u32) -> Self {
        assert!(
            entry_point < program_memory.size(),
            "entry point is out of bounds for the program memory"
        );

        Self {
            program_memory,
            data_memory,
            register_bank: RegisterBank::default(),
            program_counter: entry_point,

            instruction: None
        }
    }

    pub fn tick(&mut self) {
        
    } 

    pub fn decode(&mut self) -> Instruction {
        todo!()
    }
}

fn main() {
    let mut register_bank = RegisterBank::default();

    register_bank.store(RegisterId::Reg10, 0xFF);
    register_bank.store(RegisterId::Reg15, register_bank.fetch(RegisterId::Reg10));

    register_bank
        .dump(&mut stdout())
        .expect("failed to dump register bank");
}
