import 'package:flutter/material.dart';
import 'dart:ffi';
import 'dart:io';

import 'bridge_generated.dart';

const base = 'frb_finance'; // the name is related with cargo.toml [lib] name.
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
