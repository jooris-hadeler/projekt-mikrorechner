package assembler;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;

public class Disassembler {

    private static ArrayList<String> lines = null;

    private static int index = 0;

    public static String[] disassemble(File input) {
        lines = new ArrayList<>();

        byte[] line = new byte[Assembler.bytesPerInstruction];
        try (BufferedInputStream bis = new BufferedInputStream(new FileInputStream(input))) {
            while (bis.read(line) != -1) {
                singleInstruction(Util.convert(line));
            }
        } catch (IOException e) {
            e.printStackTrace();
        } catch (RuntimeException e) {
            System.err.println("Exception in line " + index + ": ");
            System.err.println(line);
            System.err.println(e.getMessage());
            System.exit(1);
        }

        return lines.toArray(new String[lines.size()]);
    }

    private static void singleInstruction(int instruction) {
        int opcode = getOpcode(instruction);
        if (opcode == 0) {
            int funct = getFunct(instruction);
            lines.add(Instruction.valueOfFunct(funct));
        } else {
            lines.add(Instruction.valueOfOpcode(opcode));
        }
    }

    private static int getOpcode(int line) {
        return line >>> (Assembler.bitsPerInstruction - Assembler.bitsOpcode);
    }

    private static int getFunct(int line) {
        return line & ((1 << Assembler.bitsFunct) - 1);
    }

}
