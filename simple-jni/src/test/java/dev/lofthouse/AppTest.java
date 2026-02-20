package dev.lofthouse;

import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

/**
 * Unit test for simple App.
 */
public class AppTest {

    /**
     * Integration tests that load native libraries require the library to be
     * on java.library.path (e.g. via -Djava.library.path=$HOME/local/lib).
     * Run the application with run-app.sh instead of as a unit test.
     */
    @Disabled("Native library must be on java.library.path; use run-app.sh to run")
    @Test
    public void testAddOne() {
        // System.loadLibrary("jni-library");
        // assertEquals(6, App.addOne(5));
    }
}
