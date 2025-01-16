package assembler;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;

public class Assembler {

    private static final int bytesPerInstruction = 4;
    private static final int bitsPerInstruction = 8 * bytesPerInstruction;
    private static final int bitsOpcode = 6;
    private static final int bitsRegister = 5;
    private static final int bitsFunct = 6;
    private static final int bitsImmediate = 16;
    private static final int bitsAddress = 26;

    private static int index = 0;

    private static ArrayList<Integer> out = null;

    private static HashMap<String, Integer> labels = null;

    public static int[] assemble(File input) {
        out = new ArrayList<>();
        labels = new HashMap<>();

        String line = "";
        try (BufferedReader in = new BufferedReader(new FileReader(input))) {
            while ((line = in.readLine()) != null) {
                singleInstruction(line);
            }
        } catch (IOException e) {
            e.printStackTrace();
        } catch (RuntimeException e) {
            System.err.println("Exception in line " + index + ": ");
            System.err.println(line);
            System.err.println(e.getMessage());
            System.exit(1);
        }

        int[] array = new int[out.size()];
        for (int i = 0; i < array.length; i++) {
            array[i] = out.get(i);
        }
        return array;
    }

    private static void singleInstruction(String line) {
        System.out.println(line);
        line = line.trim();
        if (line.endsWith(":")) {
            boolean doesLabelAlreadyExist = tryRememberLabel(line.substring(0, line.length() - 1));
            if (doesLabelAlreadyExist) {
                throw new RuntimeException("Label already exists in another line");
            }
            index++;
            return;
        }

        Instruction instruction = parseInstruction(line);
        if (instruction.getType() == Instruction.Type.R
                || instruction.getType() == Instruction.Type.I
                || instruction.getType() == Instruction.Type.J) {
            out.add(simpleInstruction(line));
            index++;
        } else if (instruction.getType() == Instruction.Type.MACRO) {
            int[] bits = specialInstruction(line);
            for (int i = 0; i < bits.length; i++) {
                out.add(bits[i]);
                index++;
            }
        } else {
            throw new RuntimeException("Unknown instruction: " + instruction);
        }
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

    private static int[] specialInstruction(String line) {
        String op = extractOperatorString(line);
        if (op.equalsIgnoreCase("jl")) {
            return jumpLabelInstruction(line);
        }
        return new int[0];
    }

    private static int[] jumpLabelInstruction(String line) {
        int[] out = new int[3];
        if (!tryRememberLabel(extractArgumentString(line, 0))) {
            throw new RuntimeException("Can only jump to labels already seen right now");
        }
        int address = labels.get(extractArgumentString(line, 0));
        out[0] = simpleInstruction("llo R0,R29," + (address & 0xFFFF));
        out[1] = simpleInstruction("lhi R0,R29," + (address >> 16 & 0xFFFF));
        out[2] = simpleInstruction("jr R0,R29,0");
        return out;
    }

    private static boolean tryRememberLabel(String label) {
        if (labels.containsKey(label)) {
            return true;
        }
        labels.put(label, bytesPerInstruction * index);
        return false;
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
            Instruction instruction = Instruction.valueOf(instructionString);
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
            String[] tokens = line.split(" ")[1].split(",");
            String strip = tokens[argumentIndex].strip();
            return strip;
        } catch (ArrayIndexOutOfBoundsException e) {
            throw new RuntimeException("Something went wrong while extracting argument index: " + argumentIndex);
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

}
