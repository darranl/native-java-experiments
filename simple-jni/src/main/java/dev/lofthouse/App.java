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
        final int x = 11;
        System.out.printf("addOne(%d)= %d\n", x, addOne(x));
        sayHello();
        System.out.println("Java says Goodbye World!");
    }
}
