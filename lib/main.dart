import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'screens/StaticTestScreen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

import 'dart:io';
import 'dart:async';
import 'model_tester.dart';


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
