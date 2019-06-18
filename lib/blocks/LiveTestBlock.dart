import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:vitmo_model_tester/models/roi_frame_model.dart';
import 'package:vitmo_model_tester/model_tester.dart';
import 'package:vitmo_model_tester/utils/image_converter.dart';

class LiveTestBlock {
  StreamController<CameraImage> _cameraImageStreamController =
      StreamController();
  StreamController<bool> cameraIsInitializedStreamController =
      StreamController();
  StreamController<Future<Image>> _convertedImageStreamController =
      StreamController();
  CameraController cameraController;

  bool _lrIsWorking = false;

  LiveTestBlock() {
    //load cameras?
    //load onrModel
  }

  RoiFrame liveTestFrame = RoiFrame.fromDefault();

  Future<void> prepCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    cameraController = CameraController(firstCamera, ResolutionPreset.medium);
    await cameraController.initialize();
    cameraIsInitializedStreamController.add(true);
  }

  // void onImageAvailable() {}


  void startImageStream(){
    cameraController.startImageStream((CameraImage availableYUV){
      if(_lrIsWorking == false){
        _lrIsWorking = true;
        _cameraImageStreamController.add(availableYUV);
      }
    });
  }

  

    // _cameraImageStreamController.stream.listen((CameraImage data) {
    //   Future<Image> image = ImageConverter.convertYUV420toImage(data);
    //   _convertedImageStreamController.add(image);
    // });

    // _convertedImageStreamController.stream.listen((onData) {});
}

