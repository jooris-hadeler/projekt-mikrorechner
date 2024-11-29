import java.util.*;

public class Syntax {
    
    // Instructions
    private static final Set<String> instructions = new HashSet<>(Arrays.asList(
        "alu_mov", "alu_add", "alu_sub", "alu_lsl", "alu_lsr", "alu_asr", "alu_and", "alu_or", "alu_not", "alu_cmpe", "alu_cmpne", "alu_cmpgt", "lu_cmplt"
    ));
    
    // Registers
    private static final Set<String> registers = new HashSet<>(Arrays.asList(
        "R0", "R1", "R2", "R3", "R4", "R5", "R6", "R7", "R8", "R9"
    ));
    
    // Syntax rules for operands
    private static final String immediateValueRegex = "#-?\\d+"; // Immediate value (e.g., #42)
    private static final String registerRegex = "R\\d+";          // Register (e.g., R0)
    
    // Check if a string is a valid operand
    private static boolean isValidOperand(String operand) {
        return operand.matches(immediateValueRegex) || operand.matches(registerRegex);
    }
    
    // Check if a string is a valid instruction
    private static boolean isValidInstruction(String instruction) {
        return instructions.contains(instruction);
    }
    
    public static void main(String[] args) {
        // Example assembly code
        String[] assemblyCode = {
            "alu_mov R0, #42",
            "alu_add R1, R2, R3",
            "alu_lsl R4, R4, #2",
            "alu_and R5, R6, #10"
        };
        
        // Parse and validate each assembly instruction
        for (String instruction : assemblyCode) {
            String[] parts = instruction.split("\\s*,\\s*");
            String opcode = parts[0];
            if (!isValidInstruction(opcode)) {
                System.out.println("Error: Invalid instruction '" + opcode + "'");
                continue;
            }

            if (opcode.equals("alu_mov")) {
                if (parts.length != 2) {
                    System.out.println("Error: Invalid number of operands for instruction 'alu_mov'");
                    continue;
                }
            }
                
            if (parts.length != 3) {
                System.out.println("Error: Invalid number of operands for instruction '" + opcode + "'");
                continue;
            }
            for (int i = 1; i < parts.length; i++) {
                if (!isValidOperand(parts[i])) {
                    System.out.println("Error: Invalid operand '" + parts[i] + "' for instruction '" + opcode + "'");
                    continue;
                }
            }
            System.out.println("Valid instruction: " + instruction);
        }
    }
}