## 1.Initializing Rust

* create src_rust folder & run `cargo init` command.

* add crate-type(staticlib for ios and cdylib for other platform) under lib and flutter_rust_bridge under dependencies in cargo.toml.

* run command `flutter pub add ffi flutter_rust_bridge && flutter pub add ffigen --dev && flutter pub global activate ffigen` and then install llvm.

* run command `cargo install flutter_rust_bridge_codegen cbindgen`

* copy this code in main.dart to load the rust builds.

```
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';

import 'bridge_generated.dart';

const base = 'frb_finance'; // the name is related with cargo.toml [lib] name.
final path = Platform.isWindows ? '$base.dll' : 'lib$base.so';
late final dylib = Platform.isIOS
    ? DynamicLibrary.process()
    : Platform.isMacOS
        ? DynamicLibrary.executable()
        : DynamicLibrary.open(path);
late final api = SrcRustImpl(dylib);
```


## 2. Setup IOS 

 *  run this command `flutter_rust_bridge_codegen -r src_rust/src/api.rs -d lib/bridge_generated.dart -c ios/Runner/bridge_generated.h`.

* go to src_rust folder and run `cargo lipo && cp target/universal/debug/libstep_by_step_frb.a ../ios/Runner`

* import brider_generated.h in Runner-Bridging-Header.h file & add dummy method in AppDelegate.swift file. 
```
GeneratedPluginRegistrant.register(with: self)
print("dummy_value=\(dummy_method_to_enforce_bundling())");
return super.application(application, didFinishLaunchingWithOptions: launchOptions)

```


* open the ios folder in xcode. in second Runner( Build Phases) add lib.a in Link Binary With Libraries && ignore arm64 only in second Runner build_settings.

## 3. Setup Android

* run command in src_rust folder `cargo install cargo-ndk && cargo ndk -o ../android/app/src/main/jniLibs build` ( make sure you sucessfully install NDK)


## 4. Setup Macos

* run command `flutter_rust_bridge_codegen -r src_rust/src/api.rs -d lib/bridge_generated.dart -c macos/Runner/bridge_generated.h`

* there is no .h file to import bridge_generate.h so we have to use another way. in xcode second Runner Build Settings tab, set the Objective-C Bridging Header to be Runner/bridge_generated.h. And add dummy method same as we did in ios setup part.

* run command `cargo install cargo-xcode && cargo xcode` and i will generate *.xcodeproj folder. do not open it util open macos folder in xcode and then copy *.xcodeproj and paste under Runner.

* Xcode second Runner tab , Build Phases tab in Dependencies add  step-by-step-frb-cdylib(.cdylib file) that you copy  under the Runner folder.

* Xcode second Runner tab , Build Phases tab in Link Binary with Libraries add step_by_step_frb.dylib (.dylib file).





