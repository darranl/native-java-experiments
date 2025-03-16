package dev.lofthouse;

import static java.lang.foreign.ValueLayout.JAVA_INT;

import java.lang.foreign.Arena;
import java.lang.foreign.FunctionDescriptor;
import java.lang.foreign.Linker;
import java.lang.foreign.MemorySegment;
import java.lang.foreign.SymbolLookup;
import java.lang.invoke.MethodHandle;

/**
 * Hello world!
 */
public class App {
    public static void main(String[] args) throws Throwable {
        Arena confinedArena = Arena.ofConfined();
        Linker linker = Linker.nativeLinker();
        SymbolLookup simpleLibraryLookup =
            SymbolLookup.libraryLookup("libsimple-library.so", confinedArena);

        /*
         * The first function is the say_hello function which takes no arguments,
         * returns void and prints a message to the output.
         */

        // Find the reference to the say_hello function.
        MemorySegment sayHelloSymbol = simpleLibraryLookup.find("say_hello").get();
        // Describe the function signature, this function takes no arguments and returns void.
        FunctionDescriptor sayHelloDescriptor = FunctionDescriptor.ofVoid();
        // Convert to a MethodHandle for the function.
        MethodHandle sayHelloMethodHandle = linker.downcallHandle(sayHelloSymbol, sayHelloDescriptor);
        // Invoke the function.
        sayHelloMethodHandle.invokeExact();

        /*
         * The second function is the add_one function which takes an integer as an argument,
         * adds two to it and returns the result.
         */

        // Find the reference to the add_one function.
        MemorySegment addOneSymbol = simpleLibraryLookup.find("add_one").get();
        // Describe the function signature, this function takes an integer and returns an integer.
        FunctionDescriptor addOneDescriptor = FunctionDescriptor.of(JAVA_INT, JAVA_INT);
        // Convert to a MethodHandle for the function.
        MethodHandle addOneMethodHandle = linker.downcallHandle(addOneSymbol, addOneDescriptor);
        // Invoke the function.
        int result = (int) addOneMethodHandle.invokeExact(14);
        // Display the result.
        System.out.printf("addOne(%d) = %d\n", 14, result);

        System.out.println("Hello World!");
    }
}
