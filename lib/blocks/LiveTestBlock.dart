import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:vitmo_model_tester/models/model_data.dart';
import 'package:vitmo_model_tester/models/roi_frame_model.dart';
import 'package:vitmo_model_tester/model_tester.dart';
import 'package:vitmo_model_tester/utils/image_converter.dart';
import 'package:flutter/foundation.dart';
import 'package:vitmo_model_tester/utils/image_reader.dart';
import 'package:vitmo_model_tester/utils/image_reader_stat.dart' as stat;
import 'package:flutter/scheduler.dart';
import 'package:image/image.dart' as imglib;
import 'package:tflite/tflite.dart';

class LiveTestBlock {
  ModelData model;
  ImageReader _reader;
  

  LiveTestBlock(this.model){
    prepReader(model);
  }

  StreamController<CameraImage> cameraImageStreamController =
      StreamController<CameraImage>();
  StreamController<bool> cameraIsInitializedStreamController =
      StreamController();
  StreamController <List<int>>  convertedImageStreamController = StreamController(); //
  CameraController cameraController;

  StreamController<List<String>> resultStreamController = StreamController();
 

  List<int> convertedImage;

  bool _isDoneCapturingImage = true;
  bool _isDoneConvertingImage = true;

  int _frameNumber = 0;

  RoiFrame liveTestFrame = RoiFrame.fromDefault();

  prepReader(ModelData model){
    _reader = ImageReader(model: model);
  }

  Future<void> prepCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    cameraController = CameraController(firstCamera, ResolutionPreset.medium);
    await cameraController.initialize();
    cameraIsInitializedStreamController.sink.add(true);
  }
  
  
  // void onImageAvailable() {}

  Future <void> startImageStream()async{
    cameraController.startImageStream((CameraImage availableYUV)async{
      if (!_isDoneConvertingImage) return;
      // print(_isDoneConvertingImage);
      _isDoneConvertingImage = false;
      if (false){
        List<int> imIntList = await compute(ImageConverter.convertYUV420toImage,availableYUV);
        imglib.Image image = imglib.decodeImage(imIntList);
        image = imglib.copyResize(image, width:model.imgSize, height:model.imgSize);
        image = imglib.copyRotate(image, 90);
        var result = await _reader.readImageFromBinary(image);
      }else{
        var result = await _reader.readImageFromFrame(availableYUV);
        String confidence = result[0]['confidence'].toString();
        String label = result[0]['label'].toString();
        resultStreamController.sink.add([label,confidence]);
      }
      print('converted image ${_frameNumber+=1}');
      _isDoneConvertingImage = true;
    });
  }

  void stopImageStream(){
    cameraController.stopImageStream();
  }

  void setupListeners() async{  
    // cameraImageStreamController.stream.listen((data)async{
    //   List<int> image = await ImageConverter.convertYUV420toImage(data);
    //   convertedImageStreamController.add(image);
      
    //   });

    // convertedImageStreamController.stream.listen((data){
    //   // print('converted image no $_frameNumber');
    //   _frameNumber +=1;
    //   _isDoneConvertingImage = true;
    // });

  }



    // var streamController1 = StreamController();
    // // Accessing the stream and listening for data event
    // var subscriber = streamController1.stream.listen((data) {
    //   print('Got eem! $data');
    // });
}

