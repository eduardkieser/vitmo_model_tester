import 'package:flutter/material.dart';
import 'dart:math';
import 'package:vitmo_model_tester/blocks/MultiFrameBlock.dart';
import 'package:image/image.dart' as imglib;
import '../models/roi_frame_model.dart';

class RoiFrame extends StatelessWidget {
  final MultiFrameBlock bloc;
  final int frameIndex;
  RoiFrame({this.bloc, this.frameIndex});

  List<int> latestImage;
  Color tagColor;

  void getLatestImage() {
    if (!bloc.showActualCroppedFrames) {
      return;
    }
    if (bloc.croppedImages == null) {
      return;
    }
    if (bloc.croppedImages.length <= frameIndex) {
      return;
    }

    try {
      imglib.Image img = bloc.croppedImages[frameIndex].last;
      latestImage = bloc.pngEncoder.encodeImage(img);
    } on Error {
      print('something went wrong');
    }
  }

  setTagColorFromCertainty() {
    if (!bloc.isRecording) {
      tagColor = Colors.blue;
      return;
    }
    num certainty = bloc.frames[frameIndex].certainty[0];
    if (certainty > 0.98) {
      tagColor = Colors.green;
      return;
    }
    if (certainty > 0.8) {
      tagColor = Colors.yellow;
      return;
    } else {
      tagColor = Colors.red;
      return;
    }
  }

  void moveFirstTag({DragUpdateDetails details}) {
    bloc.moveFirstTag(details, frameIndex);
  }

  void moveSecondTag({DragUpdateDetails details}) {
    bloc.moveSecondTag(details, frameIndex);
  }

  void moveFrame({DragUpdateDetails details}) {
    bloc.moveFrame(details, frameIndex);
  }

  void selectFrame() {
    //appState is called for when the order starts to matter.
    bloc.selectFrame(frameIndex);
  }

  Widget _buildFirstTag(MultiFrameBlock bloc) {
    RoiFrameModel frameData = bloc.frames[frameIndex];
    bool _isTop = frameData.firstCorner.dy < frameData.secondCorner.dy;
    bool _isLeft = frameData.firstCorner.dx < frameData.secondCorner.dx;
    double _height = frameData.tagHeight / 1;
    double _width = frameData.tagWidth / 1;

    return Positioned(
      top: _isTop
          ? frameData.firstCorner.dy
          : frameData.firstCorner.dy - _height,
      left: _isLeft
          ? frameData.firstCorner.dx
          : frameData.firstCorner.dx - _width,
      height: _height,
      width: _width,
      child: GestureDetector(
        onPanDown: (DragDownDetails details) {
          selectFrame();
        },
        onPanUpdate: (DragUpdateDetails details) {
          moveFirstTag(details: details);
        },
        child: Container(
          color: tagColor,
          child: Center(
            child: Text(frameData.label),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondTag(MultiFrameBlock bloc) {
    RoiFrameModel frameData = bloc.frames[frameIndex];
    bool _isTop = frameData.firstCorner.dy > frameData.secondCorner.dy;
    bool _isLeft = frameData.firstCorner.dx > frameData.secondCorner.dx;
    double _height = frameData.tagHeight / 1;
    double _width = frameData.tagWidth / 1;
    return Positioned(
      top: _isTop
          ? frameData.secondCorner.dy
          : frameData.secondCorner.dy - _height,
      left: _isLeft
          ? frameData.secondCorner.dx
          : frameData.secondCorner.dx - _width,
      height: _height,
      width: _width,
      child: GestureDetector(
        onPanDown: (DragDownDetails details) {
          selectFrame();
        },
        onPanUpdate: (DragUpdateDetails details) {
          moveSecondTag(details: details);
        },
        child: Container(
          color: tagColor,
          child: Center(child: Text(bloc.frames[frameIndex].currentValue.toString())),
        ),
      ),
    );
  }

  Widget _buildBorder(MultiFrameBlock bloc) {
    RoiFrameModel frameData = bloc.frames[frameIndex];
    double _top =
        [frameData.firstCorner.dy, frameData.secondCorner.dy].reduce(min);
    double _left =
        [frameData.firstCorner.dx, frameData.secondCorner.dx].reduce(min);
    double _height =
        (frameData.firstCorner.dy - frameData.secondCorner.dy).abs();
    double _width =
        (frameData.firstCorner.dx - frameData.secondCorner.dx).abs();

    Widget _buildBorderBackground(MultiFrameBlock bloc) {
      RoiFrameModel frameData = bloc.frames[frameIndex];
      if (frameData.isMMM) {
        Color color = bloc.selectedFrameIndex == this.frameIndex
            ? Colors.white.withAlpha(100)
            : Colors.white.withAlpha(50);
        Color borderColor = Colors.transparent;
        double sizeFactor = 0.6;
        return Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              width: _width *sizeFactor,
              height: _height *sizeFactor,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                      color: color,
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              width: _width *sizeFactor,
              height: _height *sizeFactor,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                      color: color,
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: (_width-_width*sizeFactor)/2,
              width: _width *sizeFactor,
              height: _height *sizeFactor,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                      color: color,
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                ),
              ),
            ),
          ],
        );
      } else {
        return Container(
            color: bloc.selectedFrameIndex == this.frameIndex
                ? Colors.white.withAlpha(100)
                : Colors.white.withAlpha(50));
      }
    }

    return Positioned(
      top: _top,
      left: _left,
      width: _width,
      height: _height,
      child: GestureDetector(
          onPanDown: (DragDownDetails details) {
            selectFrame();
          },
          onPanUpdate: (DragUpdateDetails details) {
            moveFrame(details: details);
          },
          child: Stack(children: <Widget>[
            // appState.thumbsForDisplay.length>frameIndex? appState.thumbsForDisplay[frameIndex]['img']:
            _buildBorderBackground(bloc),
            latestImage == null
                ? Container()
                : Container(
                    alignment: Alignment.bottomLeft,
                    child: Image.memory(
                      latestImage,
                      width: _width,
                      height: _height,
                      alignment: Alignment.bottomLeft,
                    )),

            Center(
                child: Text(
                    "label: ${bloc.frames[frameIndex].currentValue} \n cartainty:${bloc.frames[frameIndex].certainty[0].toStringAsFixed(2)}")),
          ])),
    );
  }

  Widget _buildFrame(MultiFrameBlock bloc) {
    getLatestImage();
    return Stack(children: <Widget>[
      _buildBorder(bloc),
      _buildFirstTag(bloc),
      _buildSecondTag(bloc),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    setTagColorFromCertainty();
    return _buildFrame(bloc);
    //
  }
}
