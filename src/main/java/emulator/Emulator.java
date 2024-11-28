package emulator;

import java.util.ArrayList;

import emulator.op.Instruction;
import emulator.op.OpCode;
import emulator.op.Register;

public class Emulator {
    private ArrayList<Instruction> instructions;
    private int instructionPointer;
    private int[] registerValues;
    private int[] memory;

    public Emulator(ArrayList<Instruction> program, int entryPoint, int memorySize) {
        this.instructions = program;
        this.memory = new int[memorySize];
        this.instructionPointer = entryPoint;
        this.registerValues = new int[32];
    }

    public int getRegister(Register reg) {
        if (reg == Register.R0) {
            return 0;
        }

        return this.registerValues[reg.getIndex()];
    }

    private void setRegister(Register reg, int value) {
        if (reg == Register.R0) {
            return;
        }

        this.registerValues[reg.getIndex()] = value;
    }

    public boolean tick() {
        if (instructionPointer > instructions.size()) {
            System.err.println("IP out of bounds, exiting!");
            System.exit(1);
        }

        Instruction current = instructions.get(instructionPointer);

        switch (current.getOpCode()) {
            case Arithmetic: {
                int op1 = getRegister(current.getOp1());
                int op2 = getRegister(current.getOp2());

                int result = switch (current.getFunction()) {
                    case 0 -> op1 + op2;
                    case 1 -> op1 - op2;
                    case 2 -> op1 & op2;
                    case 3 -> op1 | op2;
                    case 4 -> op1 ^ op2;
                    case 5 -> op1 << op2;
                    case 6 -> op1 >> op2;

                    default -> {
                        System.err.println(String.format("Invalid arithmetic function %d.", current.getFunction()));
                        System.exit(1);

                        yield 0;
                    }
                };

                setRegister(current.getDest(), result);
            }
            break;

            case LoadImmediate: {
                int value = getRegister(current.getOp1());
                value |= current.getImmediate();

                setRegister(current.getDest(), value);
            }
            break;

            case Halt:
                return false;

            default:
                System.err.println(
                        String.format("Unimplemented Instruction: %s, exiting!", current.getOpCode().toString()));
                System.exit(1);
        }

        instructionPointer++;

        return true;
    }

    public void run() {
        while (this.tick()) {
        }
        ;
    }

    public int[] getRegisterValues() {
        return registerValues;
    }

    public int[] getMemory() {
        return memory;
    }
}
