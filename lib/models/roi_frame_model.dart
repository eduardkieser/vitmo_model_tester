import 'package:flutter/material.dart';

class LensModel {
  double startingFrameWidth = 80.0;
  double startingFrameHeight = 80.0;
  double tagWidth = 40.0;
  double tagHeight = 40.0;
  Offset firstCorner = Offset(0, 0);
  Offset secondCorner = Offset(100, 100);

  String label = 'X';
  int recognisedLabel = 0;
  List<double> certainty = [0];
  List<String> currentValue = ['nan'];
  bool isMMM;

  LensModel({this.firstCorner, this.label = 'X', this.isMMM = false}) {
    secondCorner =
        firstCorner + Offset(startingFrameWidth, startingFrameHeight);
  }
}
