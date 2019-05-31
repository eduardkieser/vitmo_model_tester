
import 'package:vitmo_model_tester/models/model_data.dart';
import 'dart:async';
import 'package:vitmo_model_tester/model_tester.dart';


class StaticTestBloc{

  List<int> _binaryResults = [];

  final _resultsStreamController = StreamController<StaticPerformanceState>();

  final StreamController<int> _intStreamController = StreamController<int>();

  Stream<int> get intStream => _intStreamController.stream;

  Stream<StaticPerformanceDataState> get performanceSnapshot =>
    _resultsStreamController.stream;

  void addPerformaceSnapshot(List<PerformanceData> snapshot){
    _resultsStreamController.sink
    .add(StaticPerformanceDataState(snapshot));
  }

  void addInt(int oneIfTrue){
    _intStreamController.sink.add(oneIfTrue);
  }

  void dispose(){
    _resultsStreamController.close();
    _intStreamController.close();
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