
import 'package:vitmo_model_tester/models/model_data.dart';
import 'dart:async';
import 'package:vitmo_model_tester/model_tester.dart';


class StaticTestBloc{

  StaticTestBloc();

  final _resultsStreamController = StreamController<StaticPerformanceState>();

  Stream<StaticPerformanceDataState> get performanceSnapshot =>
    _resultsStreamController.stream;

  void addPerformaceSnapshot(List<PerformanceData> snapshot){
    _resultsStreamController.sink
    .add(StaticPerformanceDataState(snapshot));
  }

  void dispose(){
    _resultsStreamController.close();
  }

  void startStaticTest(ModelData modelSetup){
    ModelTester().startTestBatch(modelSetup, this);
  }


}

class StaticPerformanceState{
  StaticPerformanceState();
}

class StaticPerformanceDataState extends StaticPerformanceState{
  final List<PerformanceData> performanceData;
  StaticPerformanceDataState(this.performanceData);
}