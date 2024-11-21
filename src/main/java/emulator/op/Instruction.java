package emulator.op;

public class Instruction {
    private final OpCode opCode;
    private final Register dest;
    private final Register op1;
    private final Register op2;
    private final int immediate;
    private final int shiftAmount;
    private final int function;

    public Instruction(OpCode opCode, Register dest, Register op1, Register op2, int shiftAmount, int function) {
        this(opCode, dest, op1, op2, 0, shiftAmount, function);
    }

    public Instruction(OpCode opCode, Register dest, Register op, int immediate) {
        this(opCode, dest, op, Register.R0, immediate, 0, 0);
    }

    public Instruction(OpCode opCode, int address) {
        this(opCode, Register.R0, Register.R0, Register.R0, address, 0, 0);
    }

    private Instruction(OpCode opCode, Register dest, Register op1, Register op2, int immediate, int shiftAmount,
            int function) {
        this.opCode = opCode;
        this.dest = dest;
        this.op1 = op1;
        this.op2 = op2;
        this.immediate = immediate;
        this.shiftAmount = shiftAmount;
        this.function = function;
    }

    public OpCode getOpCode() {
        return opCode;
    }

    public Register getDest() {
        return dest;
    }

    public Register getOp1() {
        return op1;
    }

    public Register getOp2() {
        return op2;
    }

    public int getImmediate() {
        return immediate;
    }

    public int getShiftAmount() {
        return shiftAmount;
    }

    public int getFunction() {
        return function;
    }
}
