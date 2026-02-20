package dev.lofthouse.graal;

import static java.lang.foreign.ValueLayout.JAVA_INT;

import java.lang.foreign.FunctionDescriptor;

import org.graalvm.nativeimage.hosted.Feature;
import org.graalvm.nativeimage.hosted.RuntimeForeignAccess;

class ForeignRegistrationFeature implements Feature  {

    /**
     * Registers Foreign Function API downcall stubs for inclusion in the native image.
     *
     * <p>When GraalVM compiles to a native image it performs ahead-of-time (AOT) analysis and
     * cannot see the {@link java.lang.foreign.FunctionDescriptor} instances created dynamically at
     * runtime by {@link java.lang.foreign.Linker#downcallHandle}. Without pre-registration, the
     * AOT compiler omits the required stub code and the native image throws an
     * {@code UnsupportedOperationException} at runtime.
     *
     * <p>Registration is matched by function signature shape, not by function name, so one
     * registration covers all C functions that share the same descriptor.
     *
     * <p>The two registrations correspond to the two C functions called in {@code App}:
     * <ul>
     *   <li>{@code FunctionDescriptor.ofVoid()} — {@code void say_hello(void)}, a function
     *       that takes no arguments and returns void.</li>
     *   <li>{@code FunctionDescriptor.of(JAVA_INT, JAVA_INT)} — {@code int add_one(int)}, a
     *       function that takes a single int argument and returns an int.</li>
     * </ul>
     *
     * <p>This callback is only invoked during a native image build; on a normal JVM the
     * linker generates downcall stubs dynamically at runtime and no pre-registration is needed.
     */
    @Override
    public void duringSetup(DuringSetupAccess access) {
        // Stub for: void say_hello(void)
        RuntimeForeignAccess.registerForDowncall(FunctionDescriptor.ofVoid());
        // Stub for: int add_one(int)
        RuntimeForeignAccess.registerForDowncall(FunctionDescriptor.of(JAVA_INT, JAVA_INT));
    }

}
