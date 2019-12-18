import 'package:flutter/material.dart';
import 'dart:math';
import 'package:camera/camera.dart';
import './../widgets/roi_frame.dart';
import './../blocks/MultiFrameBlock.dart';
import './../models/roi_frame_model.dart';
import 'package:vitmo_model_tester/widgets/add_new_roi.dart';
import 'multi_frame_settings.dart';

class ZoomAndPanStack extends StatefulWidget {
  final MultiFrameBlock bloc;
  ZoomAndPanStack({this.bloc}) : super();
  createState() {
    return _ZoomAndPanStackState(bloc);
  }
}

class _ZoomAndPanStackState extends State<ZoomAndPanStack> {
  double _screenHeight;
  double _screenWidth;
  Offset _startingFocalPoint;
  Offset _focalDelta;
  MultiFrameBlock bloc;
  _ZoomAndPanStackState(this.bloc);

  /// for the zoom and pan hack
  double _zoom, _childWidth, _childHeight, _parentWidth, _parentHeight;

  void _stopScaleAndPan(ScaleEndDetails details, MultiFrameBlock bloc) {
    bloc.previousZoomScale = bloc.zoomScale;
    bloc.previousPanOffset = bloc.panOffset;
  }

  void _clipScaleAndPanData(MultiFrameBlock bloc) {
    bloc.zoomScale = [bloc.zoomScale, 1.0].reduce(max);
    double _offsetDx = bloc.panOffset.dx;
    double _offsetDy = bloc.panOffset.dy;

    ///A hack for now to use the old code for limiting zoom and pan.
    _childWidth = _screenWidth;
    _parentWidth = _screenWidth;
    _childHeight = _screenHeight;
    _parentHeight = _screenHeight;
    _zoom = bloc.zoomScale;

    ///Ensures that we cannot pan out of the screen
    _offsetDx =
        [_offsetDx, 0.5 * (_childWidth * _zoom - _parentWidth)].reduce(min);
    _offsetDx =
        [_offsetDx, 0.5 * (_parentWidth - _childWidth * _zoom)].reduce(max);
    _offsetDy =
        [_offsetDy, 0.5 * (_childHeight * _zoom - _parentHeight)].reduce(min);
    _offsetDy =
        [_offsetDy, 0.5 * (_parentHeight - _childHeight * _zoom)].reduce(max);
    bloc.panOffset = Offset(_offsetDx, _offsetDy);
    //print('zoom: $_zoom, ${bloc.panOffset}');
  }

  void _updateScaleAndPanData(
      ScaleUpdateDetails details, MultiFrameBlock bloc) {
    //print('Scale: ${details.scale}, Focal Point${details.focalPoint}');
    //_scale = _previousScale*details.scale;
    _focalDelta = details.focalPoint - _startingFocalPoint;
    bloc.zoomScale = bloc.previousZoomScale * details.scale;
    bloc.panOffset = bloc.previousPanOffset + _focalDelta;
    setState(() {
      _clipScaleAndPanData(bloc);
    });
  }

  void _startScaleAndPan(ScaleStartDetails details, MultiFrameBlock bloc) {
    _startingFocalPoint = details.focalPoint;
    //_scale = _previousScale*details.scale;
  }

  void _getViewSize(String widgetName) {
    _screenHeight = MediaQuery.of(context).size.height;
    _screenWidth = MediaQuery.of(context).size.width;
    bloc.frameWidth = _screenWidth;
    bloc.frameHeight = _screenHeight;
  }

  List<Widget> _buildRoiFrames(MultiFrameBlock bloc) {
    List<RoiFrameModel> framesModel = bloc.frames;
    List<Widget> frameWidgets = <Widget>[];
    int nFrames = framesModel.length;
    if (nFrames == 0) {
      return [
        Center(
          child: Text('no frames found'),
        )
      ];
    } else {
      for (int i = 0; i < nFrames; i++) {
        frameWidgets.add(RoiFrame(bloc: bloc, frameIndex: i));
      }
      return frameWidgets;
    }
  }

  Widget _buildPreviewWindow() {
    double angle = 0;
    if (bloc.isUpsideDown) {
      angle = pi;
    } else {
      angle = 0;
    }
    return StreamBuilder(
        stream: widget.bloc.cameraIsInitializedStreamController.stream,
        initialData: false,
        builder: (context, snapshot) {
          if (snapshot.data) {
            double _previewWidth = MediaQuery.of(context).size.width;
            _previewWidth = _previewWidth;
            double _previewHeight =
                _previewWidth / widget.bloc.cameraController.value.aspectRatio;
            return Center(
                child: Container(
              alignment: Alignment.center,
              width: _previewWidth,
              height: _previewHeight,
              child: Transform.rotate(
                  angle: angle,
                  child: CameraPreview(widget.bloc.cameraController)),
            ));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget _buildAddNewFrameWidget() {
    return StreamBuilder(
      stream: bloc.isAddingNewFrameStreamController.stream,
      initialData: false,
      builder: (context, snapshot) {
        if (snapshot.data) {
          return AddNewFrame(bloc: bloc);
        } else {
          return Center();
        }
      },
    );
  }

  _builDemoScreenWidget() {
    if (bloc.isDemoMode) {
      if (bloc.demoDisplayImages[bloc.currentDemoFrameIndex % 5] != null) {
        return bloc.demoDisplayImages[bloc.currentDemoFrameIndex % 5];
      }
    }
    return Container();
  }

  _buildSettingsMenue() {
    if (bloc.showSettingsWidget) {
      return MultiFrameSettings(bloc);
    } else {
      return Container();
    }
  }

  Widget _buildStackWidget(MultiFrameBlock bloc) {
    List<Widget> roiFrames = _buildRoiFrames(bloc);
    _getViewSize('Image Widget');
    return Stack(
      children: <Widget>[
        _buildPreviewWindow(),
        _builDemoScreenWidget(),
        Stack(
          children: roiFrames,
        ),
        _buildAddNewFrameWidget(),
        _buildSettingsMenue()
      ],
    );
  }

  Widget _buildTransformWidget(bloc) {
    _getViewSize('Transform Widget');
    return Transform.scale(
      scale: bloc.zoomScale,
      child: Transform.translate(
          offset: bloc.panOffset / bloc.zoomScale,
          child: Center(child: _buildStackWidget(bloc))),
    );
  }

  Widget buildGestureDetector(MultiFrameBlock bloc) {
    return Container(
      color: Colors.green,
      child: GestureDetector(
          onScaleStart: (ScaleStartDetails details) {
            _startScaleAndPan(details, bloc);
          },
          onScaleUpdate: (ScaleUpdateDetails details) {
            _updateScaleAndPanData(details, bloc);
          },
          onScaleEnd: (ScaleEndDetails details) {
            _stopScaleAndPan(details, bloc);
          },
          child: _buildTransformWidget(bloc)),
    );
  }

  Widget showSettingsButton(MultiFrameBlock bloc) {
    return Align(
        alignment: Alignment.bottomRight,
        child: Padding(
            padding: EdgeInsets.all(10),
            child: RawMaterialButton(
              onPressed: () {
                bloc.toggleShowSettings();
              },
              child: Icon(
                Icons.settings,
                color: Colors.white,
                size: 30.0,
              ),
              shape: new CircleBorder(),
              elevation: 2.0,
              fillColor: Colors.blue,
              padding: const EdgeInsets.all(15.0),
            )));
  }

  Widget recordStopButton(MultiFrameBlock bloc) {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
            padding: EdgeInsets.all(10),
            child: RawMaterialButton(
              onPressed: () {
                if (!bloc.isRecording){
                  bloc.isRecording = true;
                  bloc.startImageStream();
                }else{
                  bloc.isRecording = false;
                  bloc.stopImageStream();
                }
              },
              child: Icon(
                bloc.isRecording? Icons.stop:Icons.play_arrow,
                color: Colors.white,
                size: 30.0,
              ),
              shape: new CircleBorder(),
              elevation: 2.0,
              fillColor: bloc.isRecording? Colors.red:Colors.blue,
              padding: const EdgeInsets.all(15.0),
            )));
  }

  Widget addFrameButton(MultiFrameBlock bloc) {
    return Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
            padding: EdgeInsets.all(10),
            child: RawMaterialButton(
              onPressed: () {
                bloc.toggleIsAdding();
              },
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 30.0,
              ),
              shape: new CircleBorder(),
              elevation: 2.0,
              fillColor: Colors.blue,
              padding: const EdgeInsets.all(15.0),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: bloc.frameController.stream,
      initialData: bloc,
      builder: (context, snapshot) {
        return Stack(
          children: <Widget>[
            buildGestureDetector(bloc),
            (bloc.showSettingsWidget | bloc.isAddingNewframe)? Container():showSettingsButton(bloc),
            (bloc.showSettingsWidget | bloc.isAddingNewframe)? Container():recordStopButton(bloc),
            (bloc.showSettingsWidget | bloc.isAddingNewframe)? Container():addFrameButton(bloc)
          ],
        );
      },
    );
  }
}
