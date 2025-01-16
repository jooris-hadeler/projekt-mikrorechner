package assembler;

import java.util.Arrays;
import java.util.List;

public enum Instruction {

    //noop(Type.UNDEFINED, 0,0),
    add(Type.R, 0, 0),
    sub(Type.R, 0, 1),
    and(Type.R, 0, 2),
    or(Type.R, 0, 3),
    xor(Type.R, 0, 4),
    shl(Type.R, 0, 5),
    sal(Type.R, 0, 6),
    shr(Type.R, 0, 7),
    sar(Type.R, 0, 8),
    not(Type.R, 0, 9),
    lts(Type.R, 0, 10),
    gts(Type.R, 0, 11),
    ltu(Type.R, 0, 12),
    gtu(Type.R, 0, 13),
    eq(Type.R, 0, 14),
    ne(Type.R, 0, 15),
    lhi(Type.I, 1),
    llo(Type.I, 2),
    lb(Type.I, 3),
    lbu(Type.I, 4),
    lh(Type.I, 5),
    lhu(Type.I, 6),
    lw(Type.I, 7),
    lwu(Type.I, 8),
    sb(Type.I, 9),
    sh(Type.I, 10),
    sw(Type.I, 11),
    br(Type.I, 12),
    jr(Type.I, 13),
    jmp(Type.J, 14),
    push(Type.I, 15),
    pop(Type.I, 16),
    call(Type.J, 17),
    callr(Type.I, 18),
    ret(Type.UNDEFINED, 19),
    trap(Type.UNDEFINED, 20),
    halt(Type.UNDEFINED, 21),
    noop(Type.UNDEFINED, 22),

    jl(Type.UNDEFINED, -1);

    private final Type type;
    private final int opcode;
    private final int funct;

    Instruction(Type type, int opcode, int funct) {
        this.type = type;
        this.opcode = opcode;
        this.funct = funct;
    }

    Instruction(Type type, int opcode) {
        this(type, opcode, 0);
    }

    public Type getType() {
        return type;
    }

    public int getOpcode() {
        return opcode;
    }

    public int getFunct() {
        return funct;
    }

    public enum Type {
        J, // 1 Argument
        I, // 3 Arguments
        R, // 5 Arguments
        UNDEFINED,
        MACRO
    }

    public static String mostSimilarByString(String str) {
        List<String> instructions = Arrays.stream(Instruction.values()).map(Instruction::toString).toList();
        return Util.mostSimilarByString(str, instructions);
    }

}
