package assembler;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;

public class Disassembler {

    private static ArrayList<String> lines = null;

    private static int index = 0;

    public static String[] assemble(File input) {
        lines = new ArrayList<>();

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

        return lines.toArray(new String[lines.size()]);
    }

    private static String singleInstruction(int instruction) {
        return Instruction.valueOf(getOpcode(instruction));
    }

    private static int getOpcode(int line){
        return line >> (Assembler.bitsPerInstruction - Assembler.bitsOpcode);
    }

}
