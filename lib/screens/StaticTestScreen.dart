import 'package:flutter/material.dart';
import 'package:vitmo_model_tester/blocks/MultiFrameBlock.dart';
import 'package:vitmo_model_tester/models/model_data.dart';
import 'package:vitmo_model_tester/model_tester.dart';
import 'package:vitmo_model_tester/blocks/StaticTestBlock.dart';
import 'package:provider/provider.dart';
import 'package:vitmo_model_tester/screens/LiveTestScreen.dart';
import 'package:camera/camera.dart';
import 'package:vitmo_model_tester/blocks/LiveTestBlock.dart';
import 'package:vitmo_model_tester/screens/MultiFrameScreen.dart';

class StaticTestScreen extends StatefulWidget {
  // CameraDescription firstCamera;
  // StaticTestScreen(this.firstCamera);
  _StaticTestScreenState createState() => _StaticTestScreenState();
}

class _StaticTestScreenState extends State<StaticTestScreen> {
  StaticTestBloc _block = StaticTestBloc();
  ModelTester _modelTester;

  @override
  void initState() {
    super.initState();
    _modelTester = ModelTester(_block);
  }

  int _modelIndex = 0;
  double _selectedMean = 100;
  double _selectedStd = 155;

  List<ModelData> models = [
    // ModelData(
    //     model: 'assets/dragon_mini_16_48_86.tflite',
    //     labels: "assets/dragon_labels_33.txt",
    //     dataPath: 'VitmoModelTester/data',
    //     imgSize:48),
    // ModelData(
    //     model: 'assets/dragon_mini_32_48_95.tflite',
    //     labels: "assets/dragon_labels_33.txt",
    //     dataPath: 'VitmoModelTester/data',
    //     imgSize:48),
    // ModelData(
    //     model: 'assets/dragon_mini_32_48_97.tflite',
    //     labels: "assets/dragon_labels_33.txt",
    //     dataPath: 'VitmoModelTester/data',
    //     imgSize:48),
    // ModelData(
    //     model: 'assets/ed_97_48_1.tflite',
    //     labels: "assets/dragon_labels_33.txt",
    //     dataPath: 'VitmoModelTester/data',
    //     imgSize:48),
    // ModelData(
    //     model: 'assets/hardie_01.tflite',
    //     labels: "assets/dragon_labels_33.txt",
    //     dataPath: 'VitmoModelTester/data',
    //     imgSize:48),
    // ModelData(
    //     model: 'assets/hardie_02_48_99.tflite',
    //     labels: "assets/dragon_labels_33.txt",
    //     dataPath: 'VitmoModelTester/data',
    //     imgSize:48),
    ModelData(
        model: 'assets/Resnet_20.tflite',
        labels: "assets/dragon_labels_33.txt",
        dataPath: 'VitmoModelTester/data',
        imgSize: 48),
    // ModelData(
    //     model: 'assets/Resnet20_0_to_20.tflite',
    //     labels: "assets/dragon_labels_33.txt",
    //     dataPath: 'VitmoModelTester/data20',
    //     imgSize:48),
    // ModelData(
    //     model: 'assets/Resnet20_BatchFirst.tflite',
    //     labels: "assets/dragon_labels_33.txt",
    //     dataPath: 'VitmoModelTester/data20',
    //     imgSize:48),
  ];

  Widget _modelSelector() {
    List<Widget> _modelsWidgetList = List.generate(models.length, (i) {
      return FlatButton(
        child: Text(models[i].model),
        color: _modelIndex == i ? Colors.blue : null,
        onPressed: () {
          setState(() {
            _modelIndex = i;
          });
        },
      );
    });

    return Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.all(60),
        child: Column(
          children: _modelsWidgetList,
        ));
  }

  // Widget _performanceResults(){
  //   return StreamBuilder(
  //     initialData: PerformanceData(countFalse: 0, coutTrue: 0, recognitionTime: 0, result: '0'),
  //     stream: widget._block.performanceSnapshot,
  //     builder: (context, snapshot){
  //       if(snapshot.data is PerformanceData){
  //         return Container(child: Text(snapshot.data.toString()));
  //       }
  //     },
  //   );
  // }

  Widget _accResults() {
    return StreamBuilder<double>(
      stream: _block.intStream,
      initialData: 0,
      builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
        return Container(
            alignment: Alignment.center,
            child: Text(
                'mean accuracy!            ${snapshot.data.toStringAsFixed(5)}',
                style: TextStyle(fontSize: 20)));
      },
    );
  }

  Widget _durResults() {
    return StreamBuilder<double>(
      stream: _block.durationStream,
      initialData: 0,
      builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
        return Container(
            alignment: Alignment.center,
            child: Text(
              'mean recognition time ${snapshot.data.toStringAsFixed(5)}',
              style: TextStyle(fontSize: 20),
            ));
      },
    );
  }

  Widget _setMeanContainer() {
    return Container(
      // padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(20),
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      child: TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Image Mean (default = $_selectedMean)',
          hintText: 'Set Image Mean for the model to use',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          _selectedMean = double.parse(value);
        },
      ),
    );
  }

  Widget _setStdContainer() {
    return Container(
      // padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(20),
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      child: TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Image Std (default = $_selectedStd)',
          hintText: 'Set Image Std for the model to use',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          _selectedStd = double.parse(value);
        },
      ),
    );
  }

  Widget _testModelButtom() {
    return FlatButton(
      child: Text('Start Benchmark'),
      onPressed: () {
        ModelData model = models[_modelIndex];
        model.imgStd = _selectedStd;
        model.imgMean = _selectedMean;
        _block.startStaticTest(model);
      },
    );
  }

  Widget _stopTestButtom() {
    return FlatButton(
      child: Text('Stop Benchmark'),
      onPressed: () {
        _modelTester.isTesting = false;
      },
    );
  }

  Widget _clearResultsButtom() {
    return FlatButton(
      child: Text('Clear Results'),
      onPressed: () {
        _block.clearResults();
      },
    );
  }

  Widget _liveTestButton() {
    return FlatButton(
      child: Text('Live Test'),
      onPressed: () {
        ModelData model = models[_modelIndex];
        model.imgStd = _selectedStd;
        model.imgMean = _selectedMean;
        ModelPrepper.prepModel(model: model.model, labels: model.labels);
        LiveTestBlock _liveBloc = LiveTestBlock(model);
        //Instantiate live block
        //Switch route and pass live block to live screen
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LiveTestScreen(bloc: _liveBloc)),
        );
      },
    );
  }

  Widget _multiFrameButton() {
    return FlatButton(
      child: Text('MultiFrame'),
      onPressed: () {
        ModelData model = models[_modelIndex];
        model.imgStd = _selectedStd;
        model.imgMean = _selectedMean;
        ModelPrepper.prepModel(model: model.model, labels: model.labels);
        MultiFrameBlock _multiFrameBloc = MultiFrameBlock(model);
        //Instantiate live block
        //Switch route and pass live block to live screen
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MultiFrameScreen(bloc: _multiFrameBloc)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final appState = Provider.of<AppState>(context);

    return Scaffold(
      body: ListView(
        children: <Widget>[
          _modelSelector(),
          _setMeanContainer(),
          _setStdContainer(),
          _testModelButtom(),
          _stopTestButtom(),
          _accResults(),
          _durResults(),
          _clearResultsButtom(),
          _liveTestButton(),
          _multiFrameButton(),
        ],
      ),
    );
  }
}
