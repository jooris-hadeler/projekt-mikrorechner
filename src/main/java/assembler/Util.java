package assembler;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.IntBuffer;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class Util {

    public static boolean isInteger(String s) {
        try {
            Integer.parseInt(s);
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    public static int parseInt(String s, int maxBits) {
        int result = Integer.decode(s);
        if (result >= 1 << maxBits) {
            throw new RuntimeException("Integer too large");
        }
        return result;
    }

    public static String mostSimilarByString(String str, List<String> list) {
        ArrayList<String> instructions = new ArrayList<>(list);
        instructions.add(str);
        Collections.sort(instructions);
        int index = instructions.indexOf(str);
        if (index != 0) {
            return instructions.get(index - 1);
        }
        return "?";
    }

    public static List<String> readLines(File f) {
        try {
            return new ArrayList<>(new BufferedReader(new FileReader(f)).lines().toList());
        } catch (FileNotFoundException e) {
            throw new RuntimeException(e);
        }
    }

    public static void writeToFile(byte[] bits, File f) {
        try {
            FileOutputStream fos = new FileOutputStream(f);
            for (int i = 0; i < bits.length; i++) {
                fos.write(bits[i]);
            }
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    public static byte[] convert(int[] array) {
        ByteBuffer byteBuffer = ByteBuffer.allocate(array.length * 4);
        IntBuffer intBuffer = byteBuffer.asIntBuffer();
        intBuffer.put(array);

        return byteBuffer.array();
    }

    public static void writeToFile(String[] s, File f) {
        try (BufferedWriter out = new BufferedWriter(new FileWriter(f))) {
            for (int i = 0; i < s.length; i++) {
                out.write(s[i] + "\n");
            }
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    public static int convert(byte[] array) {
        ByteBuffer byteBuffer = ByteBuffer.wrap(array);
        return byteBuffer.getInt();
    }

}
