package dev.lofthouse;

import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

/**
 * Unit test for simple App.
 */
public class AppTest {

    /**
     * Integration tests that invoke native libraries require the library to be
     * on LD_LIBRARY_PATH and need --enable-native-access=ALL-UNNAMED.
     * Run the application with run-app.sh instead of as a unit test.
     */
    @Disabled("Native library must be on LD_LIBRARY_PATH; use run-app.sh to run")
    @Test
    public void testAddOne() {
        // assertEquals(6, (int) addOneMethodHandle.invokeExact(5));
    }
}
