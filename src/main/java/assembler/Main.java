package assembler;

import java.io.File;
import java.io.IOException;

import org.apache.commons.cli.*;

public class Main {

    public static File inputFile;
    public static File outputFile;
    public static boolean assemble = true;

    public static void main(String[] args) {
        getArgs(args);

        if (outputFile != null) {
            try {
                outputFile.createNewFile();
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }
    }

    public static void getArgs(String[] args) {
        Options options = new Options();

        Option fileOption = Option.builder("f").longOpt("file").hasArg().argName("file").build();
        options.addOption(fileOption);

        Option outputOption = Option.builder("o")
                                    .longOpt("output")
                                    .hasArg()
                                    .argName("file")
                                    .desc("Default value is \"default.out\"")
                                    .build();
        options.addOption(outputOption);

        Option assembleOption =
                Option.builder("a").longOpt("assemble").desc("Is given implicitly if disassemble is not given").build();
        options.addOption(assembleOption);

        Option disassembleOption = Option.builder("d").longOpt("disassemble").build();
        options.addOption(disassembleOption);

        CommandLineParser parser = new DefaultParser();
        HelpFormatter formatter = new HelpFormatter();
        try {
            // parse the command line arguments
            CommandLine line = parser.parse(options, args);
            if (!line.hasOption("f")) {
                formatter.printHelp("java -jar assembler.jar", options);
                System.exit(1);
            }
            inputFile = new File(line.getOptionValue(fileOption));
            if (!line.hasOption("o")) {
                outputFile = new File("./default.out");
            } else {
                outputFile = new File(line.getOptionValue(outputOption));
            }

            if (line.hasOption("d")) {
                assemble = false;
            }

        } catch (ParseException exp) {
            // oops, something went wrong
            System.err.println("Parsing failed.  Reason: " + exp.getMessage());
        }

        if (!outputFile.exists()) {
            System.out.println("created File: " + outputFile.getAbsolutePath());
            try {
                outputFile.createNewFile();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        if (assemble) {
            assemble();
        } else {
            disassemble();
        }

    }

    private static void assemble() {
        System.out.println("Starting assembler...");

        int[] bits = Assembler.assemble(inputFile);

        System.out.println("Wordcount: " + bits.length);
        System.out.println("Assembling complete, writing to file");

        Util.writeToFile(Util.convert(bits), outputFile);

        System.out.println("Writing to file completed");
    }

    private static void disassemble() {
        System.out.println("Starting disassembler...");

        String[] lines = Disassembler.disassemble(inputFile);

        System.out.println("Linecount: " + lines.length);
        System.out.println("Disassembling complete, writing to file");

        Util.writeToFile(lines, outputFile);

        System.out.println("Writing to file completed");

    }
}