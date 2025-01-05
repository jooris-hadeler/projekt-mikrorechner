package assembler;

public class Util {

    public static boolean isInteger(String s) {
        try{
            Integer.parseInt(s);
            return true;
        } catch(NumberFormatException e) {
            return false;
        }
    }

    public static int parseInt(String s, int maxBits) {
        int result = Integer.decode(s);
        if(result >= 1 << maxBits) {
            throw new RuntimeException("Integer too large");
        }
        return result;
    }

}
