import 'dart:async';
import 'dart:async' as prefix0;
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:vitmo_model_tester/data/entry_model.dart';
import 'package:vitmo_model_tester/models/model_data.dart';
import 'package:vitmo_model_tester/models/roi_frame_model.dart';
import 'package:vitmo_model_tester/screens/LiveTestScreen.dart';
import 'package:vitmo_model_tester/utils/image_converter.dart';
import 'package:flutter/foundation.dart';
import 'package:vitmo_model_tester/utils/image_reader.dart';
import 'package:image/image.dart' as imglib;
import 'dart:math';
import 'package:vitmo_model_tester/data/Repository.dart';
import 'package:vitmo_model_tester/screens/SignalsScreen.dart';
import 'package:vitmo_model_tester/screens/TimeSeriesChartExample.dart';

class MultiFrameBlock {
  MultiFrameBlock(this.model) {
    prepReader(model);
  }
  ModelData model;
  ImageReader _reader;
  imglib.PngEncoder pngEncoder = new imglib.PngEncoder(level: 0, filter: 0);
  List<RoiFrameModel> frames = [
    RoiFrameModel(firstCorner: Offset(50.0, 50.0), label: 'HR'),
    RoiFrameModel(firstCorner: Offset(320.0, 50.0), label: 'ABP'),
    RoiFrameModel(firstCorner: Offset(50.0, 300.0), label: 'RespR'),
    RoiFrameModel(
        firstCorner: Offset(300.0, 300.0), label: 'Sp02', isMMM: true),
  ];
  int _selectedFrameIndex;
  double zoomScale = 1.0;
  double previousZoomScale = 1.0;
  Offset panOffset = Offset(0.0, 0.0);
  Offset previousPanOffset = Offset(0.0, 0.0);
  CameraController cameraController;
  bool isAddingNewframe = false;
  String frameAddingWidgetCurrentLabel;
  Random randomGenerator = Random();
  bool showActualCroppedFrames = false;
  bool isRecording = false;
  bool invertColors = false;

  int capturePeriodInMilliSeconds = 1000;
  Timer captureTimer;

  StreamController<CameraImage> cameraImageStreamController =
      StreamController<CameraImage>();
  StreamController<bool> cameraIsInitializedStreamController =
      StreamController.broadcast();
  StreamController<Uint8List> convertedImageStreamController =
      StreamController(); //
  StreamController<Map<String, List>> resultStreamController =
      StreamController();
  StreamController<List<List<Map<String, dynamic>>>>
      structuredResultStreamController = StreamController();
  StreamController<MultiFrameBlock> frameController =
      StreamController.broadcast();

  StreamController<bool> isAddingNewFrameStreamController = StreamController();

  StreamController<Entry> captureController = StreamController();

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

  void addNewFrame(bool isMMM) {
    String label = frameAddingWidgetCurrentLabel;
    if (label == null) {
      label = "X";
    }
    frames.add(RoiFrameModel(
        firstCorner: Offset(50.0, 50.0), label: label, isMMM: isMMM));
    _selectedFrameIndex = frames.length - 1;
    frameController.sink.add(this);
    isAddingNewframe = false;
    isAddingNewFrameStreamController.add(isAddingNewframe);
    frameAddingWidgetCurrentLabel = null;
  }

  void toggleIsAdding() {
    isAddingNewframe = !isAddingNewframe;
    isAddingNewFrameStreamController.sink.add(isAddingNewframe);
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

  void addListeners() {
    resultStreamController.stream.listen((results) {
      // print(results);
      for (int frameIx = 0; frameIx < results['result'].length; frameIx++) {
        num conf = results['confidence'][frameIx][0];
        if (conf > 0.5) {
          frames[frameIx].certainty = [num.parse(conf.toStringAsFixed(2))];
          frames[frameIx].currentValue = results['result'][frameIx];
        } else {
          frames[frameIx].currentValue = ['nan'];
        }
      }
      frameController.sink.add(this);
    });
    structuredResultStreamController.stream.listen((results) {
      print(results);
      for (int frameIx = 0; frameIx < results.length; frameIx++) {
        List currentFrameData = results[frameIx];
        List frameCertainties = [];
        List frameResutls = [];
        for (Map confRes in currentFrameData) {
          num conf = confRes['confidence'];
          String res = confRes['restult'];
          if (conf > 0.5) {
            frameCertainties.add(num.parse(conf.toStringAsFixed(2)));
            frameResutls.add(res);
          } else {
            frameCertainties.add(num.parse(conf.toStringAsFixed(2)));
            frameResutls.add('nan');
          }
        }
      }
      //     num conf = results['confidence'][frameIx][0];
      //     if (conf>0.5){
      //       frames[frameIx].certainty = num.parse(conf.toStringAsFixed(2));
      //       frames[frameIx].currentValue = results['result'][frameIx][0];
      //     }
      //     else{
      //       frames[frameIx].currentValue = 'nan';
      //     }
      //   }
      //   frameController.sink.add(this);
    });
  }

  Repository repository = Repository();

  startCaptureTimer() {
    captureTimer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      storeSnapshotToDb();
    });
  }

  stopCaptureTimer() {
    captureTimer.cancel();
  }

  storeSnapshotToDb() {
    print('calling store to db');
    if (frames.length == 0) {
      return;
    }
    frames.forEach((frame) {
      print('adding frame');
      repository.insertEntry(Entry(
          // id: randomGenerator.nextInt(2^32),
          value: frame.currentValue[0] == 'nan'
              ? -1
              : int.parse(frame.currentValue[0]),
          certainty: frame.certainty[0],
          label: frame.label,
          timeStamp: DateTime.now().millisecondsSinceEpoch));
    });
  }

  List<List<imglib.Image>> croppedImages;

  Future<void> startImageStream() async {
    startCaptureTimer();

    Future<Map<String, dynamic>> runReaderOnImage(
        int frameIx, imglib.Image croppedImage) async {
      var result = await _reader.readImageFromBinary(croppedImage);
      int p0 = int.parse(result[0]['label']);
      int p1 = int.parse(result[1]['label']);
      int p2 = int.parse(result[2]['label']);
      double confidence = result[0]['confidence'] *
          result[1]['confidence'] *
          result[2]['confidence'];
      int intRes = p0 + p1 + p2;
      String res = intRes.toString();
      if (intRes == 300) {
        res = 'nan';
      }
      return {'confidence': confidence, 'res': res};
    }

    Future<List<Map<String, dynamic>>> runReaderOnFrame(
        int frameIx, List<List<imglib.Image>> croppedImages) async {
      if (frames[frameIx].isMMM) {
        return [
          await runReaderOnImage(frameIx, croppedImages[frameIx][0]),
          await runReaderOnImage(frameIx, croppedImages[frameIx][1]),
          await runReaderOnImage(frameIx, croppedImages[frameIx][2])
        ];
      } else {
        return [await runReaderOnImage(frameIx, croppedImages[frameIx][0])];
      }
    }

    cameraController.startImageStream((CameraImage availableYUV) async {
      // print('streaming');
      if (!_isDoneConvertingImage) return;
      _isDoneConvertingImage = false;
      Map<String, dynamic> cropData = {
        'frames': frames,
        'screenSize': [frameWidth, frameHeight]
      };
      Map<String, dynamic> convertCropData = {
        'image': availableYUV,
        'cropData': cropData,
        'invertColors': invertColors
      };
      croppedImages = await compute(
          ImageConverter.convertCopyRotateSetFast, convertCropData);
      List<List<String>> results = List(croppedImages.length);
      List<List<double>> confidences = List(croppedImages.length);
      List<List<Map<String, dynamic>>> structuredResutls =
          List(croppedImages.length);
      for (int frameIx = 0; frameIx < croppedImages.length; frameIx++) {
        List<Map<String, dynamic>> confResMap = await runReaderOnFrame(
            frameIx = frameIx, croppedImages = croppedImages);
        results[frameIx] = [confResMap[0]['res']];
        confidences[frameIx] = [confResMap[0]['confidence']];
        structuredResutls[frameIx] = confResMap;
      }
      resultStreamController.sink
          .add({'result': results, 'confidence': confidences});
      structuredResultStreamController.sink.add(structuredResutls);

      _isDoneConvertingImage = true;
    });
    isRecording = true;
  }

  void stopImageStream() {
    isRecording = false;
    cameraController.stopImageStream();
    stopCaptureTimer();
    // readAllEntriesFromDb();
  }

  prepReader(ModelData model) {
    _reader = ImageReader(model: model);
  }

  toggleShowRawImages() {
    showActualCroppedFrames = !showActualCroppedFrames;
  }

  toggleInvertImageColors() {
    invertColors = !invertColors;
    frameController.sink.add(this);
  }

  dispose() {
    cameraImageStreamController.close();
    cameraIsInitializedStreamController.close();
    convertedImageStreamController.close();
    resultStreamController.close();
    structuredResultStreamController.close();
    frameController.close();
    isAddingNewFrameStreamController.close();
    captureController.close();
  }
}
