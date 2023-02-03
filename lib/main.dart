import 'package:flutter/material.dart';
import 'dart:ffi';
import 'dart:io';

import 'bridge_generated.dart';

const base = 'step'; // the name is related with cargo.toml [lib] name.
final path = Platform.isWindows ? '$base.dll' : 'lib$base.so';
final dylib = Platform.isIOS
    ? DynamicLibrary.process()
    : Platform.isMacOS
        ? DynamicLibrary.executable()
        : DynamicLibrary.open(path);
 final api = FrbFinanceImpl(dylib);
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Frb',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Step By Step'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String text = "Hello from Nothing";


  Future<void> callSomeText() async {
     String result = await  api.showSomeText();
     setState(() {
        text = result;
     });
  }

  @override
  Widget build(BuildContext context) {

    callSomeText();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
             Text(
              text,
            )
          ],
        ),
      ),
    );
  }
}
