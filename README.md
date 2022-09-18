Initializing Rust.

step 1. create src_rust folder & run `cargo init` command.
step 2. add crate-type(staticlib for ios and cdylib for otherplatform) under lib and flutter_rust_bridge under dependencies in cargo.toml.
step 3. create lib.rs and api.rs under src_rust/src folder.
step 4. run command `flutter pub add ffi flutter_rust_bridge && flutter pub add ffigen --dev && flutter pub global activate ffigen` and install llvm.
step 5. run command `cargo install flutter_rust_bridge_codegen cbindgen`
step 6. copy this code in main.dart to load the rust builds.

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


For IOS 

step 1: run this command `flutter_rust_bridge_codegen -r src_rust/src/api.rs -d lib/bridge_generated.dart -c ios/Runner/bridge_generated.h`.
step 2:  got to src_rust folder and run `cargo lipo && cp target/universal/debug/libstep_by_step_frb.a ../ios/Runner`

step 3: import brider_generated.h in Runner-Bridging-Header.h file & add dummy method in AppDelegate.swift file. 
```
GeneratedPluginRegistrant.register(with: self)
print("dummy_value=\(dummy_method_to_enforce_bundling())");
return super.application(application, didFinishLaunchingWithOptions: launchOptions)

```


step 4: open the ios folder in xcode. in second Runner( Build Phases) add lib.a in Link Binary With Libraries.