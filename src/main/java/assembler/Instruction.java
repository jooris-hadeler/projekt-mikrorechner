package assembler;

public enum Instruction {

    noop(Type.UNDEFINED),
    add(Type.R),
    addu(Type.R),
    addi(Type.I),
    addiu(Type.I),
    and(Type.R),
    andi(Type.I),
    or(Type.R),
    ori(Type.I),
    shl(Type.R),
    shli(Type.I),
    sal(Type.R),
    sali(Type.I),
    shr(Type.R),
    shri(Type.I),
    sar(Type.R),
    sari(Type.I),
    not(Type.I),
    lhi(Type.J),
    llo(Type.J),
    slt(Type.R),
    slti(Type.I),
    sgt(Type.R),
    sgti(Type.I),
    ult(Type.R),
    ulti(Type.I),
    ugt(Type.R),
    ugti(Type.I),
    lb(Type.I),
    lbu(Type.I),
    lw(Type.I),
    lwu(Type.I),
    sb(Type.I),
    sh(Type.I),
    sw(Type.I),
    br(Type.J),
    jr(Type.J),
    jmp(Type.J),
    push(Type.I),
    pop(Type.I),
    call(Type.J),
    ret(Type.UNDEFINED);

    private final Type type;
    private final int opcode;

    Instruction(Type type, int opcode) {
        this.type = type;
        this.opcode = opcode;
    }

    /**
     * TODO: REMOVE TEMPORARY CONSTRUCTOR, when Opcodes have been decided
     */
    Instruction(Type type) {
        this(type, 0);
    }

    public Type getType() {
        return type;
    }

    public int getOpcode() {
        return opcode;
    }

    public enum Type {
        J, // 1 Argument
        I, // 3 Arguments
        R, // 5 Arguments
        UNDEFINED
    }

}
