package assembler;

import java.io.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class Assembler {

    public static final int bytesPerInstruction = 4;
    public static final int bitsPerInstruction = 8 * bytesPerInstruction;
    public static final int bitsOpcode = 6;
    public static final int bitsRegister = 5;
    public static final int bitsFunct = 6;
    public static final int bitsImmediate = 16;
    public static final int bitsAddress = 26;

    private static int index = 0;

    private static ArrayList<Integer> assembledData = null;

    private static HashMap<String, Integer> labels = null;
    private static HashMap<Integer, String> jumpLabels = null;

    public static int[] assemble(File input) {
        assembledData = new ArrayList<>();
        labels = new HashMap<>();
        jumpLabels = new HashMap<>();

        String line = "";
        List<String> lines = concatenateContainingIncludes(input);
        try {

            for (int i = 0; i < lines.size(); i++) {
                line = lines.get(i);
                line = preprocess(line);
                if (line.isBlank()) {
                    continue;
                }
                singleInstruction(line);
            }
            postprocess();
        } catch (RuntimeException e) {
            System.out.println("Exception in line " + index + ": ");
            System.out.println(line);
            System.out.println(e.getMessage());
            System.exit(1);
        }

        int[] array = new int[assembledData.size()];
        for (int i = 0; i < array.length; i++) {
            array[i] = assembledData.get(i);
        }
        return array;
    }

    public static List<String> concatenateContainingIncludes(File input) {
        List<String> lines = Util.readLines(input);
        ArrayList<String> concatenatedLines = new ArrayList<>();
        for (int i = lines.size() - 1; i >= 0; i--) {
            String line = lines.get(i);
            if (isInclude(line)) {
                System.out.println(line);
                concatenatedLines.addAll(0, concatenateContainingIncludes(getIncludeFile(line, input)));
            } else {
                concatenatedLines.add(0, line);
            }
        }
        return concatenatedLines;
    }

    private static void singleInstruction(String line) {
        System.out.println(index + ": " + line);
        line = line.trim();
        if (line.endsWith(":")) {
            labelInstruction(line);
            return;
        }

        Instruction instruction = parseInstruction(line);
        if (instruction.getType() == Instruction.Type.R
                || instruction.getType() == Instruction.Type.I
                || instruction.getType() == Instruction.Type.J) {
            assembledData.add(simpleInstruction(line));
            index++;
        } else if (instruction.getType() == Instruction.Type.MACRO) {
            int[] bits = macroInstruction(line);
            for (int i = 0; i < bits.length; i++) {
                assembledData.add(bits[i]);
                index++;
            }
        } else {
            throw new RuntimeException("Unknown instruction: " + instruction);
        }
    }

    private static void labelInstruction(String line) {
        saveKnownLabel(line.substring(0, line.length() - 1));
    }

    private static int simpleInstruction(String line) {
        int out = 0;
        Instruction instruction = parseInstruction(line);
        if (instruction.getType() == Instruction.Type.R) {
            out = rInstruction(line);
        } else if (instruction.getType() == Instruction.Type.I) {
            out = iInstruction(line);
        } else if (instruction.getType() == Instruction.Type.J) {
            out = jInstruction(line);
        }
        return out;
    }

    private static int rInstruction(String line) {
        Instruction instruction = parseInstruction(line);
        int opcode = instruction.getOpcode();
        int rd = parseRegister(extractArgumentString(line, 0)).getIndex();
        int rs = parseRegister(extractArgumentString(line, 1)).getIndex();
        int rt = parseRegister(extractArgumentString(line, 2)).getIndex();
        int shamt = parseShamt(extractArgumentStringWithDefault(line, 3, "0"));
        int funct = instruction.getFunct();
        int out = opcode << (bitsPerInstruction - bitsOpcode)
                | rs << (bitsPerInstruction - bitsOpcode - bitsRegister)
                | rt << (bitsPerInstruction - bitsOpcode - bitsRegister - bitsRegister)
                | rd << (bitsPerInstruction - bitsOpcode - bitsRegister - bitsRegister - bitsRegister)
                | shamt << (bitsPerInstruction - bitsOpcode - bitsRegister - bitsRegister - bitsRegister - bitsRegister)
                | funct;
        return out;
    }

    private static int iInstruction(String line) {
        Instruction instruction = parseInstruction(line);
        int opcode = instruction.getOpcode();
        int rt = parseRegister(extractArgumentString(line, 0)).getIndex();
        int rs = parseRegister(extractArgumentString(line, 1)).getIndex();
        int i = parseImmediate(extractArgumentString(line, 2));
        int out = opcode << (bitsPerInstruction - bitsOpcode)
                | rs << (bitsPerInstruction - bitsOpcode - bitsRegister)
                | rt << (bitsPerInstruction - bitsOpcode - bitsRegister - bitsRegister)
                | i;
        return out;
    }

    private static int jInstruction(String line) {
        Instruction instruction = parseInstruction(line);
        int opcode = instruction.getOpcode();
        int address = parseAddress(extractArgumentString(line, 0));
        int out = opcode << (bitsPerInstruction - bitsOpcode) | address << (
                bitsPerInstruction - bitsOpcode - bitsAddress);
        return out;
    }

    private static int[] macroInstruction(String line) {
        Instruction instruction = parseInstruction(line);
        if (instruction.equals(Instruction.jl)) {
            return jumpLabelInstruction(line);
        }
        if (instruction.equals(Instruction.noop) || instruction.equals(Instruction.nop)) {
            return noopInstruction(line);
        }
        if (instruction.equals(Instruction.bl)) {
            return branchLabelInstrcution(line);
        }
        if (instruction.equals(Instruction.halt)) {
            return haltInstruction(line);
        }
        if (instruction.equals(Instruction.call)) {
            callInstruction(line);
        }
        if (instruction.equals(Instruction.ret)) {
            retInstruction(line);
        }
        if (instruction.equals(Instruction.push)) {
            pushInstruction(line);
        }
        if (instruction.equals(Instruction.pop)) {
            popInstruction(line);
        }
        return new int[0];
    }

    private static int[] pushInstruction(String line) {
        String reg = extractArgumentString(line, 0);
        int[] out = {0, 0};
        out[0] = simpleInstruction("store " + reg + ", RSP, 0");
        out[1] = simpleInstruction("add RSP, RSP, 1");
        return out;
    }

    private static int[] popInstruction(String line) {
        String reg = extractArgumentString(line, 0);
        int[] out = {0, 0};
        out[0] = simpleInstruction("load RSP, " + reg + ", 0");
        out[1] = simpleInstruction("sub RSP, RSP, 1");
        return out;
    }

    private static int[] callInstruction(String line) {
        int[] out = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
        int address = index + out.length;
        out[0] = simpleInstruction("llo R0,R29," + (address & 0xFFFF));
        out[1] = simpleInstruction("lhi R0,R29," + (address >> 16 & 0xFFFF));
        out[2] = simpleInstruction("store RSP, R29, 0");
        out[3] = simpleInstruction("add RSP, RSP, R1");
        out[4] = simpleInstruction("store RSP, RBP, 0");
        out[5] = simpleInstruction("add RBP, RSP, R0");
        out[6] = simpleInstruction("add RSP, RSP, R1");
        String label = extractArgumentString(line, 0);
        index += 7;
        int[] jli = jumpLabelInstruction("jl " + label);
        index -= 7;
        out[7] = jli[0];
        out[8] = jli[1];
        out[9] = jli[2];
        return out;
    }

    private static int[] retInstruction(String line) {
        int[] out = {0, 0, 0, 0};
        out[0] = simpleInstruction("sub RSP, RBP, 1");
        out[1] = simpleInstruction("load RBP, RBP, 0");
        out[2] = simpleInstruction("load RSP, R29, 0");
        out[3] = simpleInstruction("jr R29");
        return out;
    }

    private static int[] haltInstruction(String line) {
        int[] out = {0, 0, 0};
        int address = index + 2;
        out[0] = simpleInstruction("llo R0,R29," + (address & 0xFFFF));
        out[1] = simpleInstruction("lhi R0,R29," + (address >> 16 & 0xFFFF));
        out[2] = simpleInstruction("jr R0,R29,0");
        return out;
    }

    private static int[] branchLabelInstrcution(String line) {
        int[] out = {0, 0, 0, 0, 0};
        String condReg = extractArgumentString(line, 0);
        String label = extractArgumentString(line, 1);
        index += 2;
        int[] jli = jumpLabelInstruction("jl " + label);
        index -= 2;
        out[0] = simpleInstruction("br " + condReg + ", R0, " + 1);
        out[1] = simpleInstruction("jmp " + 3);
        out[2] = jli[0];
        out[3] = jli[1];
        out[4] = jli[2];
        return out;
    }

    private static int[] noopInstruction(String line) {
        int noop = Instruction.noop.getOpcode() << (bitsPerInstruction - bitsOpcode);
        return new int[]{noop};
    }

    private static int[] jumpLabelInstruction(String line) {
        int[] out = {0, 0, 0};
        String label = extractArgumentString(line, 0);
        if (!labels.containsKey(label)) {
            saveUnknownLabel(label);
            return out;
        }
        int address = labels.get(label);
        out[0] = simpleInstruction("llo R0,R29," + (address & 0xFFFF));
        out[1] = simpleInstruction("lhi R0,R29," + (address >> 16 & 0xFFFF));
        out[2] = simpleInstruction("jr R0,R29,0");
        return out;
    }

    private static void saveKnownLabel(String label) {
        if (labels.containsKey(label)) {
            throw new RuntimeException("Label already exists in another line");
        }
        labels.put(label, index);
    }

    private static void saveUnknownLabel(String label) {
        jumpLabels.put(index, label);
    }

    private static String preprocess(String line) {
        if (line.contains(";")) {
            return line.split(";")[0];
        }
        return line;
    }

    private static void postprocess() {
        for (Integer jlIndex : jumpLabels.keySet()) {
            index = jlIndex;
            String label = jumpLabels.get(index);
            if (!labels.containsKey(label)) {
                throw new RuntimeException("Unknown label: " + label);
            }
            int[] instructions = jumpLabelInstruction("jl " + label);
            assembledData.set(index, instructions[0]);
            assembledData.set(index + 1, instructions[1]);
            assembledData.set(index + 2, instructions[2]);
        }
    }

    private static String extractOperatorString(String line) {
        try {
            String tokens = line.split(" ")[0];
            return tokens;
        } catch (ArrayIndexOutOfBoundsException e) {
            throw new RuntimeException("Something went wrong while extracting instruction");
        }
    }

    private static Instruction parseInstruction(String line) {
        String instructionString = extractOperatorString(line);
        try {
            Instruction instruction = Instruction.valueOf(instructionString.toLowerCase());
            return instruction;
        } catch (IllegalArgumentException e) {
            throw new RuntimeException("Unknown instruction "
                                               + instructionString
                                               + "\nDid you mean: "
                                               + Instruction.mostSimilarByString(instructionString));
        }
    }

    private static String extractArgumentString(String line, int argumentIndex) {
        try {
            String[] tokens = line.split(" ", 2)[1].split(",");
            String strip = tokens[argumentIndex].strip();
            return strip;
        } catch (ArrayIndexOutOfBoundsException e) {
            throw new RuntimeException("Something went wrong while extracting argument index: "
                                               + argumentIndex
                                               + "\n"
                                               + line
                                               + "\n");
        }
    }

    private static String extractArgumentStringWithDefault(String line, int argumentIndex, String def) {
        try {
            String[] tokens = line.split(" ")[1].split(",");
            String strip = tokens[argumentIndex].strip();
            return strip;
        } catch (ArrayIndexOutOfBoundsException e) {
            return def;
        }
    }

    private static Register parseRegister(String arg) {
        try {
            return Register.getValue(arg);
        } catch (IllegalArgumentException e) {
            return Register.R0;
        }
    }

    private static int parseShamt(String arg) {
        return Util.parseInt(arg, bitsRegister);
    }

    private static int parseImmediate(String arg) {
        return Util.parseInt(arg, bitsImmediate);
    }

    private static int parseAddress(String arg) {
        return Util.parseInt(arg, bitsAddress);
    }

    private static boolean isInclude(String line) {
        if (line.startsWith("#include")) {
            return true;
        }
        return false;
    }

    private static File getIncludeFile(String line, File relative) {

        return new File(relative.getParent() + line.split(" ")[1]);
    }

}
