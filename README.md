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

## Q&A

Some questions you may have if you want to use this project:

* **Why CMake?**

  Because I like it and I use it for everything C++ related.
* **Makefiles or Ninja?**

  It doesn't matter. As a personal preference, use Ninja. When automatically generated, Ninja is superior to Makefiles - specially because it's clever enough to run parallel builds without flags.

## What's wrong with Gradle?

This deserves its own section:

* **Android builds with Gradle requires a server running**

  You are probably doing some architectural mistakes if you need a cache server to do normal builds. It is useful if you do a daily clean build of a legacy large-scale project, but it is a bad sign when you need it when coding.
* **Gradle forces you to learn Groovy**

  This [XKCD strip](https://xkcd.com/927/) describes why another build standard doesn't work:
  ![XKCD take on standards](https://imgs.xkcd.com/comics/standards.png) 
* **Gradle forces you to use specific versions of CMake**

  This is annoying when you want to use the latest and greatest of CMake.
* **It is slow**

  The first build can take up to a minute to complete, between server starting and other Gradle shenanigans. 

  An incremental build takes precious seconds until it invokes CMake. That adds up and it is frustrating.

  Even a no-op (builds with no change) takes its time. Two seconds if the server is running, eight seconds otherwise. This is insane, compared to Ninja's 17ms.,

