import 'dart:async';
import 'dart:typed_data';
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
import 'package:vitmo_model_tester/models/roi_frame_model.dart';


class LiveTestBlock {
  ModelData model;
  ImageReader _reader;
  imglib.PngEncoder pngEncoder = new imglib.PngEncoder(level: 0, filter: 0);
  
  List<RoiFrameModel> frames = [RoiFrameModel()];

  LiveTestBlock(this.model){
    prepReader(model);
  }

  num frameWidth = 100;
  num frameHeight = 100;

  StreamController<CameraImage> cameraImageStreamController = StreamController<CameraImage>();

  StreamController<bool> cameraIsInitializedStreamController = StreamController.broadcast();

  StreamController <Uint8List>  convertedImageStreamController = StreamController(); //

  CameraController cameraController;
  StreamController<List<String>> resultStreamController = StreamController();

  StreamController <LiveTestBlock> frameController = StreamController.broadcast();

   @override
  dispose(){
    cameraImageStreamController.close();
    cameraIsInitializedStreamController.close();
    convertedImageStreamController.close();
    resultStreamController.close();
    frameController.close();
  }

  void setFrameSize(width, height){
    frameWidth = width;frameHeight=height;
  }
 
 void moveFrame(DragUpdateDetails details) {
   print('moving${frames[0].secondCorner}');
    frames[0].firstCorner = frames[0].firstCorner + details.delta / 1;
    frames[0].secondCorner = frames[0].secondCorner + details.delta / 1;

    // String firstCornerString = frames[0].firstCorner.toString();
    // String secondCornerString = frames[0].secondCorner.toString();
    // print(
    //     'First corner: $firstCornerString - Second corner: $secondCornerString');

    frameController.sink.add(this);
  }

    void moveFirstTag(DragUpdateDetails details) {

      print('moving first tag');

    frames[0].firstCorner =
        frames[0].firstCorner + details.delta / 1;
    Offset _firstCorner = frames[0].firstCorner;
    Offset _secondCorner = frames[0].secondCorner;
    // Check if the first point is almost to the right of the second point
    double _scaledWidth = frames[0].tagWidth / 1;
    double _scaledHeight = frames[0].tagHeight / 1;

    if (_firstCorner.dx > _secondCorner.dx - _scaledWidth &&
        _firstCorner.dx < _secondCorner.dx) {
      frames[0].firstCorner =
          frames[0].firstCorner + Offset(_scaledWidth, 0.0);
      frames[0].secondCorner =
          frames[0].secondCorner - Offset(_scaledWidth, 0.0);
    }
    if (_firstCorner.dx < _secondCorner.dx + _scaledWidth &&
        _firstCorner.dx > _secondCorner.dx) {
      frames[0].firstCorner =
          frames[0].firstCorner - Offset(_scaledWidth, 0.0);
      frames[0].secondCorner =
          frames[0].secondCorner + Offset(_scaledWidth, 0.0);
    }
    if (_firstCorner.dy > _secondCorner.dy - _scaledHeight &&
        _firstCorner.dy < _secondCorner.dy) {
      frames[0].firstCorner =
          frames[0].firstCorner + Offset(0.0, _scaledHeight);
      frames[0].secondCorner =
          frames[0].secondCorner - Offset(0.0, _scaledHeight);
    }
    if (_firstCorner.dy < _secondCorner.dy + _scaledHeight &&
        _firstCorner.dy > _secondCorner.dy) {
      frames[0].firstCorner =
          frames[0].firstCorner - Offset(0.0, _scaledHeight);
      frames[0].secondCorner =
          frames[0].secondCorner + Offset(0.0, _scaledHeight);
    }
    frameController.sink.add(this);
  }

  void moveSecondTag(DragUpdateDetails details) {
    print('moving second tag');
    frames[0].secondCorner =
        frames[0].secondCorner + details.delta / 1;
    Offset _firstCorner = frames[0].firstCorner;
    Offset _secondCorner = frames[0].secondCorner;
    // Check if the first point is almost to the right of the second point
    double _scaledWidth = frames[0].tagWidth / 1;
    double _scaledHeight = frames[0].tagHeight / 1;
    if (_firstCorner.dx > _secondCorner.dx - _scaledWidth &&
        _firstCorner.dx < _secondCorner.dx) {
      frames[0].firstCorner =
          frames[0].firstCorner + Offset(_scaledWidth, 0.0);
      frames[0].secondCorner =
          frames[0].secondCorner - Offset(_scaledWidth, 0.0);
    }
    if (_firstCorner.dx < _secondCorner.dx + _scaledWidth &&
        _firstCorner.dx > _secondCorner.dx) {
      frames[0].firstCorner =
          frames[0].firstCorner - Offset(_scaledWidth, 0.0);
      frames[0].secondCorner =
          frames[0].secondCorner + Offset(_scaledWidth, 0.0);
    }
    if (_firstCorner.dy > _secondCorner.dy - _scaledHeight &&
        _firstCorner.dy < _secondCorner.dy) {
      frames[0].firstCorner =
          frames[0].firstCorner + Offset(0.0, _scaledHeight);
      frames[0].secondCorner =
          frames[0].secondCorner - Offset(0.0, _scaledHeight);
    }
    if (_firstCorner.dy < _secondCorner.dy + _scaledHeight &&
        _firstCorner.dy > _secondCorner.dy) {
      frames[0].firstCorner =
          frames[0].firstCorner - Offset(0.0, _scaledHeight);
      frames[0].secondCorner =
          frames[0].secondCorner + Offset(0.0, _scaledHeight);
    }
    frameController.sink.add(this);
  }

  List<int> convertedImage;

  // bool _isDoneCapturingImage = true;
  bool _isDoneConvertingImage = true;

  int _frameNumber = 0;

  prepReader(ModelData model){
    _reader = ImageReader(model: model);
  }

  Future<void> prepCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    cameraController = CameraController(firstCamera, ResolutionPreset.high);
    await cameraController.initialize();
    cameraIsInitializedStreamController.sink.add(true);
  }

  Future <void> startImageStream()async{
    cameraController.startImageStream((CameraImage availableYUV)async{
      if (!_isDoneConvertingImage) return;
      // print(_isDoneConvertingImage);
      _isDoneConvertingImage = false;
      // either use one or the other processing pipeline
      print('first corner: ${frames[0].firstCorner} second corner: ${frames[0].secondCorner}');
      if (true){
        print('starting compute set');
        imglib.Image image = await compute(ImageConverter.convertYUV420toImageFast, availableYUV);
        Map<String, dynamic> cropData = {
          'image':image, 
          'frames':frames,
          'screenSize':[frameWidth,frameHeight]};
        imglib.Image croppedImage = await compute(ImageConverter.cropRotate, cropData);
        List<int> imgForDisplay = await compute(ImageConverter.encodePng, croppedImage);

        var result = await _reader.readImageFromBinary(croppedImage);
        // // var intImg = _reader.imageToByteListUint8(image, model.imgSize);
        int p0 = int.parse(result[0]['label']);
        int p1 = int.parse(result[1]['label']);
        int p2 = int.parse(result[2]['label']);

        int intRes = p0+p1+p2;
        String res = intRes.toString();

        convertedImageStreamController.sink.add(imgForDisplay);
        resultStreamController.sink.add([res,'shrug']);
      }else{
        var result = await _reader.readImageFromFrame(availableYUV);
        String confidence = result[0]['confidence'].toString();
        String label = result[0]['label'].toString();

        int p0 = int.parse(result[0]['label']);
        int p1 = int.parse(result[1]['label']);
        int p2 = int.parse(result[2]['label']);

        int intRes = p0+p1+p2;
        String res = intRes.toString();

        resultStreamController.sink.add([res,'shrug']);
      }
      print('converted image ${_frameNumber+=1}');
      _isDoneConvertingImage = true;
    });
  }

  void stopImageStream(){
    cameraController.stopImageStream();
  }
}

