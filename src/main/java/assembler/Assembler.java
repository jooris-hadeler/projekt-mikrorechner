package assembler;

import java.io.*;
import java.util.HashMap;

public class Assembler {

    private static final int bytesPerInstruction = 4;
    private static final int bitsPerInstruction = 8 * bytesPerInstruction;
    private static final int bitsOpcode = 6;
    private static final int bitsRegister = 5;
    private static final int bitsFunct = 6;
    private static final int bitsImmediate = 5;
    private static final int bitsAddress = 5;

    private static int index = 0;

    private static int[] out = null;

    private static HashMap<String, Integer> labels = null;


    public static int[] assemble(File input) {
        out = null;
        labels = new HashMap<>();


        String line = null;
        try(BufferedReader in = new BufferedReader(new FileReader(input))) {
            int lines = (int) in.lines().count();
            out = new int[lines * bytesPerInstruction];
            while((line = in.readLine()) != null) {
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
        return out;
    }

    private static void singleInstruction(String line){
        line = line.trim();
        if(line.endsWith(":")){
            boolean doesLabelAlreadyExist = tryRememberLabel(line);
            if(doesLabelAlreadyExist) throw new RuntimeException("Label already exists in another line");
            return;
        }
        index++;
        String[] tokens = line.split(" "); //tokens[0] is the instruction, tokens[1] is the arguments
        Instruction instruction = Instruction.valueOf(tokens[0]);
        if(instruction.getType() == Instruction.Type.J){

        } else if(instruction.getType() == Instruction.Type.I){

        } else if(instruction.getType() == Instruction.Type.R){

        } else {
            throw new RuntimeException("Unknown instruction type " + instruction);
        }

    }

    private static int jInstruction(String line){

    }

    private static int simpleIInstruction(String line){
        String[] tokens = line.split(" "); //tokens[0] is the instruction, tokens[1] is the arguments
        Instruction instruction = Instruction.valueOf(tokens[0]);
        int opcode = instruction.getOpcode();
        int rs = 1;
        int rt = 1;
        int i = 1;
        int out = opcode << bitsPerInstruction - bitsOpcode | rs << (bitsPerInstruction - bitsRegister - bitsOpcode) | rt << b;
        return 0;
    }

    private static int rInstruction(String line){
        return 0;
    }

    private static boolean tryRememberLabel(String line){
        if(labels.containsKey(line)) return true;
        labels.put(line, index);
        return false;
    }

    private static String extractArgument(String line, int argumentIndex){
        String[] tokens = line.split(" ")[1].split(",");
        return tokens[argumentIndex];
    }

}
