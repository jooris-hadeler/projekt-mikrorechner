package emulator.op;

public enum OpCode {
    Arithmetic("R"),

    LoadImmediate("I"),

    Halt("H");

    public String type;

    OpCode(String type) {
        this.type = type;
    }

    public String getType() {
        return type;
    }
}
