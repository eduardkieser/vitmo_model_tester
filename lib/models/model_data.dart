
import 'package:flutter/material.dart';

class ModelData{
  String model;
  String labels;
  String dataPath;
  double imgMean;
  double imgStd;
  int imgSize;
  ModelData({this.model, this.labels, this.dataPath, this.imgMean, this.imgStd, this.imgSize});
}

class PerformanceData{
  int coutTrue;
  int countFalse;
  double recognitionTime;
  String result;
  PerformanceData({this.coutTrue,this.countFalse, this.recognitionTime, this.result});
}

class AppState with ChangeNotifier{

int _trueCount = 0;
int _falseCount = 0;

void incTrue(){
  ++_trueCount;
  notifyListeners();
}
void incFalse(){
  ++_falseCount;
  notifyListeners();
}


}