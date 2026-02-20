#include <stdio.h>

#include "dev_lofthouse_App.h"
#include "simple-library.h"

/* JNIEnv* and jclass are required by the JNI ABI for all native methods,
 * even when the implementation does not use them. */
JNIEXPORT void JNICALL Java_dev_lofthouse_App_sayHello (JNIEnv *, jclass)
{
    say_hello();
}

JNIEXPORT jint JNICALL Java_dev_lofthouse_App_addOne (JNIEnv * env, jclass jcl, jint x)
{
    return add_one(x);
}
