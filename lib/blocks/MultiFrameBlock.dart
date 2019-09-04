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

class MultiFrameBlock {
  MultiFrameBlock(this.model) {
    prepReader(model);
  }
  ModelData model;
  ImageReader _reader;
  imglib.PngEncoder pngEncoder = new imglib.PngEncoder(level: 0, filter: 0);
  List<RoiFrameModel> frames = [
    RoiFrameModel(firstCorner: Offset(50.0, 50.0)),
    RoiFrameModel(firstCorner: Offset(50.0, 50.0))
  ];
  int _selectedFrameIndex;
  double zoomScale = 1.0;
  double previousZoomScale = 1.0;
  Offset panOffset = Offset(0.0, 0.0);
  Offset previousPanOffset = Offset(0.0, 0.0);
  CameraController cameraController;

  StreamController<CameraImage> cameraImageStreamController =
      StreamController<CameraImage>();
  StreamController<bool> cameraIsInitializedStreamController =
      StreamController.broadcast();
  StreamController<Uint8List> convertedImageStreamController =
      StreamController(); //
  StreamController<List<String>> resultStreamController = StreamController();
  StreamController<MultiFrameBlock> frameController =
      StreamController.broadcast();

  // //////////////////////////////////////////////////////////////////////////////
  // ////////////////// Lots of zooming and panning stuff /////////////////////////
  // //////////////////////////////////////////////////////////////////////////////

  void moveFirstTag(DragUpdateDetails details, int frameIndex) {
    _selectedFrameIndex = frameIndex;
    frames[_selectedFrameIndex].firstCorner =
        frames[_selectedFrameIndex].firstCorner + details.delta / zoomScale;
    Offset _firstCorner = selectedFrame.firstCorner;
    Offset _secondCorner = selectedFrame.secondCorner;
    // Check if the first point is almost to the right of the second point
    double _scaledWidth = selectedFrame.tagWidth / zoomScale;
    double _scaledHeight = selectedFrame.tagHeight / zoomScale;

    if (_firstCorner.dx > _secondCorner.dx - _scaledWidth &&
        _firstCorner.dx < _secondCorner.dx) {
      selectedFrame.firstCorner =
          selectedFrame.firstCorner + Offset(_scaledWidth, 0.0);
      selectedFrame.secondCorner =
          selectedFrame.secondCorner - Offset(_scaledWidth, 0.0);
    }
    if (_firstCorner.dx < _secondCorner.dx + _scaledWidth &&
        _firstCorner.dx > _secondCorner.dx) {
      selectedFrame.firstCorner =
          selectedFrame.firstCorner - Offset(_scaledWidth, 0.0);
      selectedFrame.secondCorner =
          selectedFrame.secondCorner + Offset(_scaledWidth, 0.0);
    }
    if (_firstCorner.dy > _secondCorner.dy - _scaledHeight &&
        _firstCorner.dy < _secondCorner.dy) {
      selectedFrame.firstCorner =
          selectedFrame.firstCorner + Offset(0.0, _scaledHeight);
      selectedFrame.secondCorner =
          selectedFrame.secondCorner - Offset(0.0, _scaledHeight);
    }
    if (_firstCorner.dy < _secondCorner.dy + _scaledHeight &&
        _firstCorner.dy > _secondCorner.dy) {
      selectedFrame.firstCorner =
          selectedFrame.firstCorner - Offset(0.0, _scaledHeight);
      selectedFrame.secondCorner =
          selectedFrame.secondCorner + Offset(0.0, _scaledHeight);
    }
    frameController.sink.add(this);
  }

  void moveSecondTag(DragUpdateDetails details, int frameIndex) {
    _selectedFrameIndex = frameIndex;
    frames[_selectedFrameIndex].secondCorner =
        frames[_selectedFrameIndex].secondCorner + details.delta / zoomScale;
    Offset _firstCorner = selectedFrame.firstCorner;
    Offset _secondCorner = selectedFrame.secondCorner;
    // Check if the first point is almost to the right of the second point
    double _scaledWidth = selectedFrame.tagWidth / zoomScale;
    double _scaledHeight = selectedFrame.tagHeight / zoomScale;
    if (_firstCorner.dx > _secondCorner.dx - _scaledWidth &&
        _firstCorner.dx < _secondCorner.dx) {
      selectedFrame.firstCorner =
          selectedFrame.firstCorner + Offset(_scaledWidth, 0.0);
      selectedFrame.secondCorner =
          selectedFrame.secondCorner - Offset(_scaledWidth, 0.0);
    }
    if (_firstCorner.dx < _secondCorner.dx + _scaledWidth &&
        _firstCorner.dx > _secondCorner.dx) {
      selectedFrame.firstCorner =
          selectedFrame.firstCorner - Offset(_scaledWidth, 0.0);
      selectedFrame.secondCorner =
          selectedFrame.secondCorner + Offset(_scaledWidth, 0.0);
    }
    if (_firstCorner.dy > _secondCorner.dy - _scaledHeight &&
        _firstCorner.dy < _secondCorner.dy) {
      selectedFrame.firstCorner =
          selectedFrame.firstCorner + Offset(0.0, _scaledHeight);
      selectedFrame.secondCorner =
          selectedFrame.secondCorner - Offset(0.0, _scaledHeight);
    }
    if (_firstCorner.dy < _secondCorner.dy + _scaledHeight &&
        _firstCorner.dy > _secondCorner.dy) {
      selectedFrame.firstCorner =
          selectedFrame.firstCorner - Offset(0.0, _scaledHeight);
      selectedFrame.secondCorner =
          selectedFrame.secondCorner + Offset(0.0, _scaledHeight);
    }
    frameController.sink.add(this);
  }

  void moveFrame(DragUpdateDetails details, int frameIndex) {
    _selectedFrameIndex = frameIndex;
    frames[_selectedFrameIndex].firstCorner =
        frames[_selectedFrameIndex].firstCorner + details.delta / zoomScale;
    frames[_selectedFrameIndex].secondCorner =
        frames[_selectedFrameIndex].secondCorner + details.delta / zoomScale;

    frameController.sink.add(this);
  }

  void addNewFrame() {
    frames.add(RoiFrameModel(firstCorner: Offset(50.0, 50.0)));
    _selectedFrameIndex = frames.length - 1;
    frameController.sink.add(this);
  }

  void removeSelectedFrame() {
    if (frames.length - 1 < _selectedFrameIndex) {
      _selectedFrameIndex = frames.length - 1;
    }
    frames.removeAt(selectedFrameIndex);
    frameController.sink.add(this);
  }

  void selectFrame(int tappedFrame) {
    _selectedFrameIndex = tappedFrame;
    frameController.sink.add(this);
  }

  RoiFrameModel get selectedFrame {
    return frames[_selectedFrameIndex];
  }

  int get selectedFrameIndex {
    return _selectedFrameIndex;
  }

  // ///////////////////////////////////////////////////////////////////////////////
  // ////////////////////// Camera stuff ///////////////////////////////////////////
  // ///////////////////////////////////////////////////////////////////////////////
  Future<void> prepCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    cameraController = CameraController(firstCamera, ResolutionPreset.high);
    await cameraController.initialize();
    cameraIsInitializedStreamController.sink.add(true);
  }

  // ///////////////////////////////////////////////////////////////////////////////
  // /////////////////////////// Vision Stuff //////////////////////////////////////
  // ///////////////////////////////////////////////////////////////////////////////

  num frameWidth = 100;
  num frameHeight = 100;
  bool _isDoneConvertingImage = true;
  int _frameNumber = 0;

  void addListeners(){
    resultStreamController.stream.listen((results){
      print(results);
      for (int i=0;i<results.length;i++){
        frames[i].currentValue = results[i];
      }
      frameController.sink.add(this);
    });
  }

  Future<void> startImageStream() async {
    cameraController.startImageStream((CameraImage availableYUV) async {
      // print('streaming');
      if (!_isDoneConvertingImage) return;

      _isDoneConvertingImage = false;
      // print('converting');
      imglib.Image image = await compute(ImageConverter.convertYUV420toImageFast, availableYUV);
      Map<String, dynamic> cropData = {
        'image': image,
        'frames': frames,
        'screenSize': [frameWidth, frameHeight]
      };
      // print('cropping');
      List<imglib.Image> croppedImages = await compute(ImageConverter.cropRotateSet, cropData);
      // List<int> imgForDisplay = await compute(ImageConverter.encodePng, croppedImage);
      List<String> results = List(croppedImages.length);
      for (int ix=0; ix<croppedImages.length;ix++){
        var result = await _reader.readImageFromBinary(croppedImages[ix]);
        int p0 = int.parse(result[0]['label']);
        int p1 = int.parse(result[1]['label']);
        int p2 = int.parse(result[2]['label']);
        int intRes = p0 + p1 + p2;
        String res = intRes.toString();
        results[ix]=res;
      }
      // convertedImageStreamController.sink.add(imgForDisplay);
      resultStreamController.sink.add(results);
      // print(results);

      // print('converted image ${_frameNumber += 1}');
      _isDoneConvertingImage = true;
    });
  }

  void stopImageStream(){
    cameraController.stopImageStream();
  }

  prepReader(ModelData model) {
    _reader = ImageReader(model: model);
  }

  dispose() {
    cameraImageStreamController.close();
    cameraIsInitializedStreamController.close();
    convertedImageStreamController.close();
    resultStreamController.close();
    frameController.close();
  }
}
