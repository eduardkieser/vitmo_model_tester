
import 'package:vitmo_model_tester/models/model_data.dart';
import 'dart:async';
import 'package:vitmo_model_tester/model_tester.dart';


class StaticTestBloc{

  List<int> _binaryResults = [];
  List<int> _durationResutls = [];

  final StreamController<double> _intStreamController = StreamController<double>();

  Stream<double> get intStream => _intStreamController.stream;

  final StreamController<double> _durationStreamController = StreamController<double>();

  Stream<double> get durationStream => _durationStreamController.stream;

  // final _resultsStreamController = StreamController<StaticPerformanceState>();

  // Stream<StaticPerformanceDataState> get performanceSnapshot =>
  //   _resultsStreamController.stream;

  // void addPerformaceSnapshot(List<PerformanceData> snapshot){
  //   _resultsStreamController.sink
  //   .add(StaticPerformanceDataState(snapshot));
  // }

  void addInt(int oneIfTrue){
    _binaryResults.add(oneIfTrue);
    double _result = _binaryResults.reduce((a,b)=>a+b) / _binaryResults.length;
    _intStreamController.sink.add((_result*100));
  }

  void addRecognitionDuration(int duration){
    _durationResutls.add(duration);
    double _meanDuration = _durationResutls.reduce((a,b)=>a+b)/_durationResutls.length;
    _durationStreamController.sink.add(_meanDuration);
  }

  void clearResults(){
    _binaryResults = [];
  }

  void dispose(){
    // _resultsStreamController.close();
    _intStreamController.close();
    _durationStreamController.close();
  }

  void startStaticTest(ModelData modelSetup){
    ModelTester(this).startTestBatch(modelSetup, this);
  }


}

class StaticPerformanceState{
  StaticPerformanceState();
}

class StaticPerformanceDataState extends StaticPerformanceState{
  final List<PerformanceData> performanceData;
  StaticPerformanceDataState(this.performanceData);
}