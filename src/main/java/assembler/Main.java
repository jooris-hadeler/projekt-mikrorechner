package assembler;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import org.apache.commons.cli.*;

public class Main {


    public static File inputFile;
    public static File outputFile;

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

        Option stringOption = Option.builder("o").longOpt("output").hasArg().argName("file")
                .desc("Default value is \"default.out\"").build();
        options.addOption(stringOption);

        CommandLineParser parser = new DefaultParser();
        HelpFormatter formatter = new HelpFormatter();
        try {
            // parse the command line arguments
            CommandLine line = parser.parse(options, args);
            if(!line.hasOption("f")) {
                formatter.printHelp("java -jar assembler.jar", options);
            }
            inputFile = new File(line.getOptionValue(fileOption));
            if(!line.hasOption("o")) {
                outputFile = new File("default.out");
            }else{
                outputFile = new File(line.getOptionValue(fileOption));
            }

        } catch (ParseException exp) {
            // oops, something went wrong
            System.err.println("Parsing failed.  Reason: " + exp.getMessage());
        }
    }
}