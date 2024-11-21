package emulator;

import java.util.ArrayList;

import emulator.op.Instruction;
import emulator.op.OpCode;
import emulator.op.Register;

public class Main {
    public static void main(String[] args) {
        ArrayList<Instruction> prog = new ArrayList<>();
        prog.add(Instruction.I(OpCode.LoadImmediate, Register.R2, Register.R0, 50));
        prog.add(Instruction.I(OpCode.LoadImmediate, Register.R3, Register.R2, 0));
        prog.add(Instruction.R(OpCode.Arithmetic, Register.R1, Register.R2, Register.R3, 0, 0));
        prog.add(Instruction.Halt());

        Emulator emulator = new Emulator(prog, 0, 256);
        emulator.run();

        System.out.println(emulator.getRegister(Register.R1));
        System.out.println(emulator.getRegister(Register.R2));
        System.out.println(emulator.getRegister(Register.R3));
    }
}
