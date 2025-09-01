package dev.lofthouse.graal;

import static java.lang.foreign.ValueLayout.JAVA_INT;

import java.lang.foreign.FunctionDescriptor;

import org.graalvm.nativeimage.hosted.Feature;
import org.graalvm.nativeimage.hosted.RuntimeForeignAccess;

class ForeignRegistrationFeature implements Feature  {

    @Override
    public void duringSetup(DuringSetupAccess access) {
        // Ability to call function with no arguments and no return value.
        RuntimeForeignAccess.registerForDowncall(FunctionDescriptor.ofVoid());
        RuntimeForeignAccess.registerForDowncall(FunctionDescriptor.of(JAVA_INT, JAVA_INT));
    }

}
