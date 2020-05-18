import 'package:flutter/material.dart';
import 'package:vitmo_model_tester/blocks/MultiFrameBlock.dart';
import 'package:vitmo_model_tester/model_tester.dart';
import 'package:vitmo_model_tester/models/model_data.dart';
import 'package:vitmo_model_tester/screens/MultiFrameScreen.dart';
import 'package:client/server/recorder_service_impl.dart';
import 'package:grpc/grpc.dart' as grpc;


class RouteGenerator{

  static Route<dynamic>generateRoute(RouteSettings settings){
    final args = settings.arguments;
    
    switch (settings.name){
      case '/':
      return MaterialPageRoute(builder: (_){
        double _selectedMean = 100;
        double _selectedStd = 155;
        ModelData model = ModelData(
        model: 'assets/Resnet_20.tflite',
        labels: "assets/dragon_labels_33.txt",
        dataPath: 'VitmoModelTester/data',
        imgSize: 48);
        model.imgStd = _selectedStd;
        model.imgMean = _selectedMean;
        ModelPrepper.prepModel(model: model.model, labels: model.labels);
        MultiFrameBlock _multiFrameBloc = MultiFrameBlock(model);

        // RecorderServiceImpl recorderServiceImpl = RecorderServiceImpl(_multiFrameBloc);
        // final server = grpc.Server([recorderServiceImpl]);
        // server.serve(port: 8080); 


        return MultiFrameScreen(bloc: _multiFrameBloc,);
      });
      // case 'page2'
      default:
      return MaterialPageRoute(builder: (context) => Center(child: Text('shiiiit'),),
      );
    }
  }
}