import 'package:flutter/material.dart';

class RoiFrameModel{
  double startingFrameWidth=80.0;
  double startingFrameHeight=80.0;
  double tagWidth = 40.0;
  double tagHeight = 40.0;
  Offset firstCorner = Offset(0,0);
  Offset secondCorner = Offset(100,100);

  final String label;
  int recognisedLabel = 0;
  double certainty = 0;
  String currentValue = 'nan';

  RoiFrameModel({this.firstCorner, this.label='X'}){
    secondCorner = firstCorner+Offset(startingFrameWidth, startingFrameHeight);
  }
}