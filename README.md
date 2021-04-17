# android-ndk-without-gradle

This is an example of building and packaging an Android NDK application without using Gradle - it relies on CMake only.

Again, this is an example. It's not a tutorial and you should think twice before using this in any form of production.

## TL;DR

If you want to try this project:

1. Run something like this: `sh build.sh <path-to-ndk>`
1. ???
1. Profit

This assumes you have the Android NDK installed and CMake.

## With a little bit more details:

After installing the Android SDK and its NDK, it will be in a folder like this: `<path-to-sdk>/ndk/<ndk-version>`.

The CMake project is a little bit metamorphic. When run without any parameters, it behaves like the type of CMake file you would normally use with Gradle - i.e. it generates a shared library.

The real trick is the secret sauce added when you run it with the special flag (`-DUMBRELLA=1`). That flag will take over the build.

First, it adds the project itself as an ExternalProject without the special flag. This allows CMake to run the build just like Gradle would do. It does it four times, one per ABI.

Then it is a matter of calling Android tools to package and sign the APK.

There are extra tricks to make this work: the shared library definition also have a `install` directive. This seems to be required by CMake. And the ExternalProject invocation puts the output of any library in the exact place Android will expect it in the APK.

