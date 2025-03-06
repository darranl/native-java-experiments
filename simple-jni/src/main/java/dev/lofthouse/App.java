package dev.lofthouse;

/**
 * Hello world!
 */
public class App {

    /*
     * Native Methods.
     */
    private static native void sayHello();
    private static native int addOne(final int x);

    public static void main(String[] args) {
        System.out.println("Java says Hello World!");
        System.out.println(System.getProperty("java.library.path"));

        System.loadLibrary("jni-library");
        //System.loadLibrary("simple-library");

        final int x = 11;
        System.out.printf("addOne(%d)= %d\n", x, addOne(x));
        sayHello();
        System.out.println("Java says Goodbye World!");
    }
}
