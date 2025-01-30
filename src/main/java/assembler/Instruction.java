package assembler;

import java.util.Arrays;
import java.util.List;

public enum Instruction {

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
    load(Type.I, 3),
    store(Type.I, 4),
    br(Type.I, 5),
    jr(Type.I, 6),
    jmp(Type.J, 7),

    push(Type.MACRO, -1),
    pop(Type.MACRO, -1),
    call(Type.MACRO, -1),
    ret(Type.MACRO, -1),
    halt(Type.MACRO, -1),
    jl(Type.MACRO, -1),
    bl(Type.MACRO, -1),
    noop(Type.MACRO, 63, 0),
    nop(Type.MACRO, 63, 0);

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

    public static String valueOfOpcode(int value) {
        return Arrays.stream(Instruction.values()).filter(e -> e.opcode == value).findFirst().get().toString();
    }

    public static String valueOfFunct(int value) {
        return Arrays.stream(Instruction.values())
                     .filter(e -> e.funct == value && e.opcode == 0)
                     .findFirst()
                     .get()
                     .toString();
    }
}
