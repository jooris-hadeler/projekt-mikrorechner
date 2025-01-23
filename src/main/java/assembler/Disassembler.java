package assembler;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;

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
        lines.add(Instruction.valueOf(getOpcode(instruction)));
    }

    private static int getOpcode(int line) {
        return line >> (Assembler.bitsPerInstruction - Assembler.bitsOpcode);
    }

}
