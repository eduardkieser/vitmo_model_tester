import 'package:flutter/material.dart';


class RoiFrame{

  Offset p1;
  Offset p2;

  RoiFrame({this.p1, this.p2});

  RoiFrame.fromDefault(){
    p1 = Offset(0, 0.25);
    p2 = Offset(1, 0.75);
  }
}