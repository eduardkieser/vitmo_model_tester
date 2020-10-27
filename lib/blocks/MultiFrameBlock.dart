import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imglib;
import 'package:vitmo_model_tester/data/Repository.dart';
import 'package:vitmo_model_tester/data/entry_model.dart';
import 'package:vitmo_model_tester/models/model_data.dart';
import 'package:vitmo_model_tester/models/roi_frame_model.dart';
import 'package:vitmo_model_tester/utils/image_converter.dart';
import 'package:vitmo_model_tester/utils/image_reader.dart';
import 'package:beatcounter_recorder/application/bloc/recorder_bloc.dart';
import 'package:beatcounter_recorder/infrastructure/config_repository.dart';

class MultiFrameBlock extends RecorderBloc {
  ConfigRepository configRepository;

  MultiFrameBlock(this.model, this.configRepository) : super(configRepository) {
    prepReader(model);
    loadDemoImageAssets();
  }
  ModelData model;
  ImageReader _reader;
  imglib.PngEncoder pngEncoder = imglib.PngEncoder(level: 0, filter: 0);
  List<RoiFrameModel> frames = [
    RoiFrameModel(firstCorner: Offset(50.0, 50.0), label: 'HR'),
    RoiFrameModel(firstCorner: Offset(320.0, 50.0), label: 'ABP'),
    RoiFrameModel(firstCorner: Offset(50.0, 300.0), label: 'RespRate'),
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
  bool isDemoMode = false;
  bool showSettingsWidget = false;
  bool isUpsideDown = false;

  static int n_demo_frames = 25;
  List<imglib.Image> demoImages = List<imglib.Image>(n_demo_frames);
  List<Image> demoDisplayImages = List<Image>(n_demo_frames);
  int currentDemoFrameIndex = 0;
  Timer demoTimer;

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

  ////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////// Networking things! ////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////

  // I need to open a stream (controller) that has to listen to incomming requests
  // from the recorder_service and do things.
  //

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

  void checkDelete(DragEndDetails details, int frameIndex) {
    // The logic that I would like to hold here is that if more than 1/4 of the frame is outside the screen on the top, it will be deleted.
    _selectedFrameIndex = frameIndex;
    double _top = [selectedFrame.firstCorner.dy, selectedFrame.secondCorner.dy]
        .reduce(min);
    double _height =
        (selectedFrame.firstCorner.dy - selectedFrame.secondCorner.dy).abs();
    bool _isFarOut;
    if ((_top < 0) & (_top.abs() > _height / 4)) {
      _isFarOut = true;
    } else {
      _isFarOut = false;
    }
    if (_isFarOut) {
      removeSelectedFrame();
    }
  }

  void addNewFrame(bool isMMM) {
    String label = frameAddingWidgetCurrentLabel;
    if (label == null) {
      return;
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
    frameController.sink.add(this);
  }

  void removeSelectedFrame() {
    if (frames.length - 1 < _selectedFrameIndex) {
      _selectedFrameIndex = frames.length - 1;
    }
    if (croppedImages != null) {
      croppedImages.removeAt(selectedFrameIndex);
    }
    if (frames != null) {
      frames.removeAt(selectedFrameIndex);
    }
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
    structuredResultStreamController.stream.listen((results) {
      for (int frameIx = 0; frameIx < results.length; frameIx++) {
        List currentFrameData = results[frameIx];
        List<double> frameCertainties = [];
        List<String> frameResutls = [];
        for (Map confRes in currentFrameData) {
          num conf = confRes['confidence'];
          String res = confRes['res'];
          if (conf > 0.5) {
            frameCertainties.add(num.parse(conf.toStringAsFixed(2)));
            frameResutls.add(res);
          } else {
            frameCertainties.add(num.parse(conf.toStringAsFixed(2)));
            frameResutls.add('nan');
          }
        }
        frames[frameIx].currentValue = frameResutls;
        frames[frameIx].certainty = frameCertainties;
      }
      frameController.sink.add(this);
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
    if (frames.isEmpty) {
      return;
    }
    int timeStamp = DateTime.now().millisecondsSinceEpoch;
    frames.forEach((frame) {
      if (frame.currentValue.length == 1) {
        repository.insertEntry(Entry(
            value: frame.currentValue[0] == 'nan'
                ? 0
                : int.parse(frame.currentValue[0]),
            certainty: frame.certainty[0],
            label: frame.label,
            timeStamp: timeStamp));
        return;
      } else {
        for (int i = 0; i < frame.currentValue.length; i++) {
          repository.insertEntry(Entry(
              value: frame.currentValue[i] == 'nan'
                  ? 0
                  : int.parse(frame.currentValue[i]),
              certainty: frame.certainty[i],
              label: '${frame.label}_$i',
              timeStamp: timeStamp));
        }
      }
    });
  }

  List<List<imglib.Image>> croppedImages;

  Future<void> startImageStream() async {
    startCaptureTimer();

    // Factor these functinos out of here
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
      if (frameIx >= frames.length) {
        return [
          {'confidence': 0.0, 'res': 'nan'}
        ];
      }
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

    await cameraController.startImageStream((CameraImage availableYUV) async {
      if (!_isDoneConvertingImage) return;
      _isDoneConvertingImage = false;
      Map<String, dynamic> cropData = {
        'frames': frames,
        'screenSize': [frameWidth, frameHeight]
      };
      Map<String, dynamic> convertCropData = {
        'image': availableYUV,
        'cropData': cropData,
        'invertColors': invertColors,
        'isDemoMode': isDemoMode,
        'demoImage': demoImages[currentDemoFrameIndex % n_demo_frames],
        'isUpsideDown': isUpsideDown
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
      structuredResultStreamController.sink.add(structuredResutls);

      _isDoneConvertingImage = true;
    });
    isRecording = true;
    frameController.sink.add(this);
  }

  void stopImageStream() {
    isRecording = false;
    if (cameraController != null) {
      cameraController.stopImageStream();
    }

    stopCaptureTimer();
    frameController.sink.add(this);
  }

  prepReader(ModelData model) {
    _reader = ImageReader(model: model);
  }

  toggleShowRawImages() {
    showActualCroppedFrames = !showActualCroppedFrames;
    frameController.sink.add(this);
  }

  toggleInvertImageColors() {
    invertColors = !invertColors;
    frameController.sink.add(this);
  }

  toggleDemoMode() {
    isDemoMode = !isDemoMode;
    updateDemoIndexTimer();
    frameController.sink.add(this);
  }

  toggleShowSettings() {
    showSettingsWidget = !showSettingsWidget;
    frameController.sink.add(this);
  }

  loadDemoImageAssets() async {
    for (int fIx = 0; fIx < n_demo_frames; fIx++) {
      String fileName = 'assets/images/${fIx + 1}.png';
      ByteData data = await rootBundle.load(fileName);
      List<int> imgFile =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      demoImages[fIx] = imglib.decodeImage(imgFile);
      demoDisplayImages[fIx] = Image.asset(fileName);
    }
  }

  updateDemoIndexTimer() {
    if (isDemoMode) {
      demoTimer = Timer.periodic(Duration(seconds: 5), (Timer t) {
        currentDemoFrameIndex++;
      });
    } else {
      if (demoTimer.isActive) {
        demoTimer.cancel();
      }
    }
  }

  sendAsCSV() {
    repository.getCsvFromRepo();
  }

  flipScreen() {
    isUpsideDown = !isUpsideDown;

    if (isUpsideDown) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
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
