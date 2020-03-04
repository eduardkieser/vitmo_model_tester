import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/StaticTestScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // @override
  // void initState() async {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    SystemChrome.setEnabledSystemUIOverlays([]);

    return MaterialApp(
      title: 'ONR Benchmarker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StaticTestScreen(),
    );
  }
}
