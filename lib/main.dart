import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'screens/StaticTestScreen.dart';
import 'package:provider/provider.dart';
import 'package:vitmo_model_tester/models/model_data.dart';

import 'dart:io';
import 'dart:async';
import 'model_tester.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ONR Benchmarker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider<AppState>(
          builder: (_) => AppState(),
          child: StaticTestScreen(),
        ));
    
  }
}
