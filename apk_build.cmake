include(ExternalProject)

set(ANDROID_SDK_ROOT $ENV{ANDROID_SDK_ROOT} CACHE PATH "Path to Android SDK")

file(GLOB ANDROID_BUILD_TOOLS_VERSIONS "${ANDROID_SDK_ROOT}/build-tools/*")
list(POP_BACK ANDROID_BUILD_TOOLS_VERSIONS ANDROID_BUILD_TOOLS_LATEST)
set(ANDROID_BUILD_TOOLS_DIR "${ANDROID_BUILD_TOOLS_LATEST}" CACHE PATH "Path to Android build tools (i.e. where to find aapt2, etc)")

file(GLOB ANDROID_NDK_VERSIONS "${ANDROID_SDK_ROOT}/ndk/*")
list(POP_BACK ANDROID_NDK_VERSIONS ANDROID_NDK_LATEST)
set(ANDROID_NDK "${ANDROID_NDK_LATEST}" CACHE PATH "Path to Android NDK")

file(GLOB ANDROID_JAR_VERSIONS "${ANDROID_SDK_ROOT}/platforms/*")
list(POP_BACK ANDROID_JAR_VERSIONS ANDROID_JAR_LATEST)
set(ANDROID_JAR "${ANDROID_JAR_LATEST}/android.jar" CACHE PATH "Path to Android JAR")

find_program(AAPT2     NAMES aapt2     PATHS ${ANDROID_BUILD_TOOLS_DIR} REQUIRED)
find_program(APKSIGNER NAMES apksigner PATHS ${ANDROID_BUILD_TOOLS_DIR} REQUIRED)
find_program(ZIPALIGN  NAMES zipalign  PATHS ${ANDROID_BUILD_TOOLS_DIR} REQUIRED)

macro(setup_variant VARIANT)
  ExternalProject_Add(${PROJECT_NAME}-${VARIANT}
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}
    EXCLUDE_FROM_ALL TRUE
    CMAKE_ARGS
    -DANDROID_ABI=${VARIANT}
    -DANDROID_NDK=${ANDROID_NDK}
    -DANDROID_STL=c++_static
    -DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_BINARY_DIR}/install/${VARIANT}
    -DCMAKE_LIBRARY_OUTPUT_DIRECTORY=${CMAKE_CURRENT_BINARY_DIR}/apk/lib/${VARIANT}
    -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake
    )
endmacro()
setup_variant(arm64-v8a)
setup_variant(armeabi-v7a)
setup_variant(x86)
setup_variant(x86_64)

set(MANIFEST "${CMAKE_CURRENT_SOURCE_DIR}/AndroidManifest.xml")
set(RESOURCES "${CMAKE_CURRENT_SOURCE_DIR}/res")

set(VALUES_STRING "${CMAKE_CURRENT_BINARY_DIR}/values_strings.arsc.flat")

set(ALIGNED_APK "${CMAKE_CURRENT_BINARY_DIR}/app.apk")
set(RESOURCES_APK "${CMAKE_CURRENT_BINARY_DIR}/app.res.apk")
set(UNALIGNED_APK "${CMAKE_CURRENT_BINARY_DIR}/app.unaligned.apk")

set(KEYSTORE "${CMAKE_CURRENT_SOURCE_DIR}/keystore.jks")

# keytool -genkeypair -keystore keystore.jks -alias androidkey -validity 10000 -keyalg RSA -keysize 2048 -storepass android -keypass android

add_custom_command(
  OUTPUT ${VALUES_STRING}
  COMMAND ${AAPT2} compile ${RESOURCES}/values/strings.xml -o ${CMAKE_CURRENT_BINARY_DIR}
  DEPENDS ${RESOURCES}/values/strings.xml
  )
add_custom_command(
  OUTPUT ${RESOURCES_APK}
  COMMAND ${AAPT2} link ${VALUES_STRING} -o ${RESOURCES_APK} --manifest ${MANIFEST} -I ${ANDROID_JAR}
  DEPENDS ${MANIFEST} ${VALUES_STRING}
  )
add_custom_command(
  OUTPUT ${UNALIGNED_APK}
  COMMAND ${CMAKE_COMMAND} -E tar x ${RESOURCES_APK}
  COMMAND ${CMAKE_COMMAND} -E tar c ${UNALIGNED_APK} --format=zip .
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/apk
  DEPENDS
  ${RESOURCES_APK}
  ${PROJECT_NAME}-armeabi-v7a
  ${PROJECT_NAME}-arm64-v8a
  ${PROJECT_NAME}-x86
  ${PROJECT_NAME}-x86_64
  )
add_custom_command(
  OUTPUT ${ALIGNED_APK}
  COMMAND ${ZIPALIGN} -p -f -v 4 ${UNALIGNED_APK} ${ALIGNED_APK}
  COMMAND ${APKSIGNER} sign --in ${ALIGNED_APK} -ks ${KEYSTORE} --ks-key-alias androidkey --ks-pass pass:android --key-pass pass:android
  DEPENDS ${UNALIGNED_APK}
  )

add_custom_target(apk ALL DEPENDS ${ALIGNED_APK})

# TODO: Maybe use a install target to do a `adb install`
