package emulator;

import emulator.op.Instruction;
import emulator.op.OpCode;
import emulator.op.Register;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;

public class Loader {

    public ArrayList<Instruction> load() {
        if (Main.isFileBinary) {
            return null;
        } else {
            return loadInstructionsAsStrings();
        }
    }

    private ArrayList<Instruction> loadInstructionsAsStrings() {
        ArrayList<Instruction> instructions = new ArrayList<>();
        try {
            BufferedReader fr = new BufferedReader(new FileReader(Main.inputFile));
            String line;
            int lineIndex = 1;
            while ((line = fr.readLine()) != null) {
                Instruction i = null;
                try {
                    i = loadLine(line);
                } catch (Exception e) {
                    System.err.println("ERROR IN LINE " + lineIndex + "\n" + e.getMessage());
                    e.printStackTrace();
                    return null;
                }
                instructions.add(i);
                lineIndex++;
            }
        } catch (IOException | IllegalArgumentException e) {
            e.printStackTrace();
        }
        return instructions;
    }

    public static Instruction loadLine(String line) {
        Instruction i = null;
        String[] tokens = line.split(" ");
        OpCode opCode = OpCode.valueOf(tokens[0]);
        if (opCode.type.equals("R")) {
            Register dest = Register.getValue(tokens[1]);
            Register r1 = Register.getValue(tokens[2]);
            Register r2 = Register.getValue(tokens[3]);
            int shift = Integer.parseInt(tokens[4]);
            int function = Integer.parseInt(tokens[5]);
            i = Instruction.R(opCode, dest, r1, r2, shift, function);
        }
        if (opCode.type.equals("I")) {
            Register dest = Register.getValue(tokens[1]);
            Register op = Register.getValue(tokens[2]);
            int immediate = Integer.parseInt(tokens[3]);
            i = Instruction.I(opCode, dest, op, immediate);
        }
        if (opCode.type.equals("J")) {
            int address = Integer.parseInt(tokens[1]);
            i = Instruction.J(opCode, address);
        }
        if (opCode.type.equals("H")) {
            i = Instruction.Halt();
        }
        return i;
    }

    public static void saveMemoryNewline(int[] memory) {
        try {
            BufferedWriter bw = new BufferedWriter(new FileWriter(Main.memoryFile));
            for (int i = 0; i < memory.length; i++) {
                bw.write(memory[i] + "\n");
            }
            bw.flush();
            bw.close();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    public static void saveMemory(int[] memory) {
        try {
            BufferedWriter bw = new BufferedWriter(new FileWriter(Main.memoryFile));
            for (int i = 0; i < memory.length; i++) {
                bw.write(memory[i]);
            }
            bw.flush();
            bw.close();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    public static void saveRegistersNewline(int[] registers) {
        try {
            BufferedWriter bw = new BufferedWriter(new FileWriter(Main.registerFile));
            for (int i = 0; i < registers.length; i++) {
                bw.write(registers[i] + "\n");
            }
            bw.flush();
            bw.close();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    public static void saveRegisters(int[] registers) {
        try {
            BufferedWriter bw = new BufferedWriter(new FileWriter(Main.registerFile));
            for (int i = 0; i < registers.length; i++) {
                bw.write(registers[i]);
            }
            bw.flush();
            bw.close();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}

