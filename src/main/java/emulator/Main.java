package emulator;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import emulator.op.Instruction;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;

public class Main {

    public static Emulator emulator;

    public static File inputFile;
    public static boolean isFileBinary;
    public static File memoryFile;
    public static int memorySize;
    public static File registerFile;

    public static void main(String[] args) {
        getArgs(args);
        Loader loader = new Loader();
        ArrayList<Instruction> instructions = loader.load();

        if (instructions == null) {
            return;
        }

        Emulator emulator = new Emulator(instructions, 0, 256);
        emulator.run();

        if (memoryFile != null) {
            try {
                memoryFile.createNewFile();
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
            Loader.saveMemoryNewline(emulator.getMemory());
        }
        if (registerFile != null) {
            try {
                registerFile.createNewFile();
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
            Loader.saveRegistersNewline(emulator.getRegisterValues());
        }
    }

    public static void getArgs(String[] args) {
        Options options = new Options();

        Option fileOption = Option.builder("f").longOpt("file").hasArg().argName("file").build();
        options.addOption(fileOption);

        Option stringOption = Option.builder("s").longOpt("string").build();
        options.addOption(stringOption);

        Option memoryFileOption = Option.builder("m").longOpt("memoryfile").hasArg().argName("file").build();
        options.addOption(memoryFileOption);

        Option registerFileOption = Option.builder("r").longOpt("registersfile").hasArg().argName("file").build();
        options.addOption(registerFileOption);

        Option memorySizeOption = Option.builder().longOpt("memory").hasArg().argName("size").build();
        options.addOption(memorySizeOption);

        CommandLineParser parser = new DefaultParser();
        try {
            // parse the command line arguments
            CommandLine line = parser.parse(options, args);
            inputFile = new File(line.getOptionValue(fileOption));
            System.out.println(line.getOptionValue(memoryFileOption));
            memoryFile = line.hasOption(memoryFileOption) ? new File(line.getOptionValue(memoryFileOption)) : null;
            registerFile =
                    line.hasOption(registerFileOption) ? new File(line.getOptionValue(registerFileOption)) : null;
            isFileBinary = !line.hasOption(stringOption);
            memorySize =
                    line.hasOption(memorySizeOption) ? Integer.parseInt(line.getOptionValue(memorySizeOption)) : 255;

        } catch (ParseException exp) {
            // oops, something went wrong
            System.err.println("Parsing failed.  Reason: " + exp.getMessage());
        }
    }
}

/*
package emulator;

import java.util.ArrayList;

import emulator.op.Instruction;
import emulator.op.OpCode;
import emulator.op.Register;

public class Main {
    public static void main(String[] args) {
        ArrayList<Instruction> prog = new ArrayList<>();
        prog.add(Instruction.I(OpCode.LoadImmediate, Register.R2, Register.R0, 50));
        prog.add(Instruction.I(OpCode.LoadImmediate, Register.R3, Register.R2, 0));
        prog.add(Instruction.R(OpCode.Arithmetic, Register.R1, Register.R2, Register.R3, 0, 0));
        prog.add(Instruction.Halt());

        Emulator emulator = new Emulator(prog, 0, 256);
        emulator.run();

        System.out.println(emulator.getRegister(Register.R1));
        System.out.println(emulator.getRegister(Register.R2));
        System.out.println(emulator.getRegister(Register.R3));
    }
}

 */