## 1.Initializing Rust

* Run this when starting a new project only: create src_rust folder & run `cargo init` command.

* Install Cargo tools:

```sh
cargo install cargo-xcode cargo-lip
```

* Install target for different platforms:

```sh
# Android
rustup target add \
    aarch64-linux-android \
    armv7-linux-androideabi \
    x86_64-linux-android \
    i686-linux-android
    
# IOS
rustup target add \ 
    aarch64-apple-ios \
    x86_64-apple-ios \ 
    aarch64-apple-ios-sim \
```


* add crate-type(staticlib for ios and cdylib for other platform) under lib and flutter_rust_bridge under dependencies in cargo.toml.

* run command `flutter pub add ffi flutter_rust_bridge && flutter pub add ffigen --dev && flutter pub global activate ffigen` and then install llvm.

* run command `cargo install flutter_rust_bridge_codegen`

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

## 2. Setup iOS 

1. Generates bindings code between Rust and Flutter, also utilities for Xcode.

```sh
flutter_rust_bridge_codegen -r src_rust/src/api.rs -d lib/bridge_generated.dart -c ios/Runner/bridge_generated.h
```

2. Add `lib` target in `Cagro.toml` likes below:

```toml
[lib]
name = "personal_finance_frb"
crate-type = ["staticlib", "lib"]
```

3. Builds Rust code into `lib.a` and copies the `lib.a` into `Runner` directory so that Xcode can search for the lib while linking

```sh
cd src_rust \
cargo lipo && cp target/universal/debug/libstep_by_step_frb.a ../ios/Runner 
```

3. Declares `#import "bridge_generated.h"` in `Runner-Bridging-Header.h` file & add dummy method in `AppDelegate.swift` file likes below:

```swift
GeneratedPluginRegistrant.register(with: self)
print("dummy_value=\(dummy_method_to_enforce_bundling())"); // add dummy method here
return super.application(application, didFinishLaunchingWithOptions: launchOptions)
```


4. Open the `ios` folder in Xcode, in **Targets** > **Runner** > **Build Phases** tab, check the `lib.a` was in **Link Binary With Libraries**.
(If there's error maybe we should ignore arm64 only in **Targets** > **Runner** > **Build Settings**)

## 3. Setup Android

* run command in src_rust folder `cargo install cargo-ndk && cargo ndk -o ../android/app/src/main/jniLibs build` ( make sure you sucessfully install NDK)


## 4. Setup Macos

1. Generates bindings code between Rust and Flutter, also utilities for Xcode.

```sh
flutter_rust_bridge_codegen -r src_rust/src/api.rs -d lib/bridge_generated.dart -c macos/Runner/bridge_generated.h
```

2. There is no bridging header file to tell Xcode about our `bridge generated` code. We have to tell Xcode another way, in **Targets** > **Runner** > **Build Settings** tab, set the **Objective-C Bridging Header** to be **Runner/bridge_generated.h**. And add dummy method same as we did in ios setup part:

```swift
// ...
override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    print("dummy_value=\(dummy_method_to_enforce_bundling())"); // add dummy method here
    return false
  }
// ...  
```

3. Run `cargo xcode` within Rust directory and it will generate `*.xcodeproj` folder inside Rust project directory. DO NOT open it util you add generated `*.xcodeproj` under `macos` Xcode project.

![not found](./img/add_xcodeproj.png)

4. Linking the libs by opening **Targets** > **Runner** > **Build Phases** tab:

- In **Dependencies** add dynamic lib `step-by-step-frb-cdylib(.cdylib file)`.

- In **Link Binary** with Libraries add static lib `step_by_step_frb.a (.a file)`.

![not found](./img/build_phases.png)



