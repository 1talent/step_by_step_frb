.PHONY: macos ios-build android-build ios-build-gen android-build-gen macos-build-gen macos-build
RUST_DIR := src_rust
RUST_API_PATH := ${RUST_DIR}/src/api.rs
DART_LIB_PATH := lib/bridge_generated.dart 
DART_DECL_PATH := lib/bridge_definitions.dart 
BUILD_NAME := step


ios-build-gen:
	flutter_rust_bridge_codegen \
		-r ${RUST_API_PATH} \
		-d ${DART_LIB_PATH} \
		--dart-decl-output ${DART_DECL_PATH} \
		-c ios/Runner/bridge_generated.h;
	cd ${RUST_DIR} && cargo lipo && cp target/universal/debug/lib${BUILD_NAME}.a ../ios/Runner;

ios-build:
	cd ${RUST_DIR} && cargo lipo && cp target/universal/debug/lib${BUILD_NAME}.a ../ios/Runner;

android-build-gen:
	flutter_rust_bridge_codegen \
		-r ${RUST_API_PATH} \
		-d ${DART_LIB_PATH} \
		--dart-decl-output ${DART_DECL_PATH};
	cd ${RUST_DIR} && cargo ndk -t x86 -t armeabi-v7a -t arm64-v8a -t x86_64 \
		 -o ../android/app/src/main/jniLibs build;


android-build:
	cd ${RUST_DIR} && cargo ndk \
	 	-t x86 -t armeabi-v7a -t arm64-v8a -t x86_64 \
		-o ../android/app/src/main/jniLibs build;


macos-build-gen:
	flutter_rust_bridge_codegen \
		-r ${RUST_API_PATH} \
		-d ${DART_LIB_PATH} \
		--dart-decl-output ${DART_DECL_PATH} \
		-c macos/Runner/bridge_generated.h;
	cd ${RUST_DIR} && cargo xcode;


macos-build:
	cd ${RUST_DIR} && cargo xcode;