#include <android/log.h>
#include <android/native_activity.h>

JNIEXPORT
void ANativeActivity_onCreate(ANativeActivity * /*activity*/, void * /*savedState*/, size_t /*savedStateSize*/) {
  __android_log_print(ANDROID_LOG_INFO, "hello-world", "Well, this worked!"); // NOLINT
}
