import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import 'package:vitmo_model_tester/blocks/MultiFrameBlock.dart';

import '../models/roi_frame_model.dart';

class RoiData {
  List<int> latestImage;
  Color tagColor;
  List<Color> backgroundColors;
}

class RoiFrame extends StatelessWidget {
  final MultiFrameBlock bloc;
  final int frameIndex;
  RoiFrame({this.bloc, this.frameIndex});

  void getLatestImage(RoiData roiData) {
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
      roiData.latestImage = bloc.pngEncoder.encodeImage(img);
    } on Error {
      print('something went wrong');
    }
  }

  setTagColorFromCertainty(RoiData roiData) {
    if (!bloc.isRecording) {
      roiData.tagColor = Colors.blue;
      return;
    }
    num certainty = bloc.frames[frameIndex].certainty.reduce(min);
    if (certainty > 0.98) {
      roiData.tagColor = Colors.green;
      return;
    }
    if (certainty > 0.8) {
      roiData.tagColor = Colors.yellow;
      return;
    } else {
      roiData.tagColor = Colors.red;
      return;
    }
  }

  setBackgroundColorsFromCertainty(RoiData roiData) {
    roiData.backgroundColors = [Colors.white, Colors.white, Colors.white];
    List<num> certainties = bloc.frames[frameIndex].certainty;
    if (certainties.length == 1) {
      return;
    }
    if (!bloc.isRecording) {
      return;
    }
    for (var i = 0; i < certainties.length; i++) {
      if (certainties[i] > 0.98) {
        roiData.backgroundColors[i] = Colors.green;
        continue;
      }
      if (certainties[i] > 0.8) {
        roiData.backgroundColors[i] = Colors.yellow;
        continue;
      } else {
        roiData.backgroundColors[i] = Colors.red;
        continue;
      }
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

  void checkDelete(DragEndDetails details) {
    bloc.checkDelete(details, frameIndex);
  }

  void selectFrame() {
    //appState is called for when the order starts to matter.
    bloc.selectFrame(frameIndex);
  }

  String parseValeString() {
    List valueList = bloc.frames[frameIndex].currentValue;
    String valueString = '';
    valueList.forEach((value) {
      valueString = valueString + '$value ';
    });
    return valueString;
  }

  String parseCertaintyString() {
    List<double> certaintyList = bloc.frames[frameIndex].certainty;
    double certainty = certaintyList.reduce(min);
    return certainty.toStringAsFixed(2);
  }

  Widget _buildFirstTag(MultiFrameBlock bloc, RoiData roiData) {
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
          decoration: BoxDecoration(
              color: roiData.tagColor,
              borderRadius: BorderRadius.all(Radius.circular(5))),
          child: Center(
            child: Text(frameData.label),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondTag(MultiFrameBlock bloc, RoiData roiData) {
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
          // padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: roiData.tagColor,
              borderRadius: BorderRadius.all(Radius.circular(5))),
          child: Center(
              child: AutoSizeText(
            parseValeString(),
            textAlign: TextAlign.center,
          )),
        ),
      ),
    );
  }

  Widget _buildBorder(MultiFrameBlock bloc, RoiData roiData) {
    RoiFrameModel frameData = bloc.frames[frameIndex];
    double _top =
        [frameData.firstCorner.dy, frameData.secondCorner.dy].reduce(min);
    double _left =
        [frameData.firstCorner.dx, frameData.secondCorner.dx].reduce(min);
    double _height =
        (frameData.firstCorner.dy - frameData.secondCorner.dy).abs();
    double _width =
        (frameData.firstCorner.dx - frameData.secondCorner.dx).abs();

    bool _isFarOut;
    if ((_top < 0) & (_top.abs() > _height / 4)) {
      _isFarOut = true;
    } else {
      _isFarOut = false;
    }

    Widget _buildDeleteBackground(MultiFrameBlock bloc) {
      return Container(
        decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.all(Radius.circular(5))),
        child: Center(
          child: Icon(
            Icons.remove_circle,
            color: Colors.red,
            size: 100,
          ),
        ),
      );
    }

    Widget _buildBorderBackground(MultiFrameBlock bloc) {
      int alpha = bloc.selectedFrameIndex == this.frameIndex ? 100 : 50;
      RoiFrameModel frameData = bloc.frames[frameIndex];
      if (frameData.isMMM) {
        Color borderColor = Colors.transparent;
        double sizeFactor = 0.495;
        return Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              width: _width * sizeFactor,
              height: _height * sizeFactor,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                      color: roiData.backgroundColors[0].withAlpha(alpha),
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              width: _width * sizeFactor,
              height: _height * sizeFactor,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                      color: roiData.backgroundColors[1].withAlpha(alpha),
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: (_width - _width * sizeFactor) / 2,
              width: _width * sizeFactor,
              height: _height * sizeFactor,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                      color: roiData.backgroundColors[2].withAlpha(alpha),
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                ),
              ),
            ),
          ],
        );
      } else {
        return Container(
            decoration: BoxDecoration(
                color: bloc.selectedFrameIndex == this.frameIndex
                    ? Colors.white.withAlpha(100)
                    : Colors.white.withAlpha(50),
                borderRadius: BorderRadius.all(Radius.circular(5))));
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
          onPanEnd: (DragEndDetails details) {
            checkDelete(details);
          },
          child: Stack(children: <Widget>[
            // appState.thumbsForDisplay.length>frameIndex? appState.thumbsForDisplay[frameIndex]['img']:
            _isFarOut
                ? _buildDeleteBackground(bloc)
                : _buildBorderBackground(bloc),
            roiData.latestImage == null
                ? Container()
                : Container(
                    alignment: Alignment.bottomLeft,
                    child: Image.memory(
                      roiData.latestImage,
                      width: _width,
                      height: _height,
                      alignment: Alignment.bottomLeft,
                    )),

            _isFarOut
                ? Container()
                : Center(
                    child: Text(
                        "label: ${parseValeString()} \n cartainty:${parseCertaintyString()}")),
          ])),
    );
  }

  Widget _buildFrame(MultiFrameBlock bloc, RoiData roiData) {
    getLatestImage(roiData);
    return Stack(children: <Widget>[
      _buildBorder(bloc, roiData),
      _buildFirstTag(bloc, roiData),
      _buildSecondTag(bloc, roiData),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    RoiData roiData = RoiData();
    setTagColorFromCertainty(roiData);
    setBackgroundColorsFromCertainty(roiData);
    return _buildFrame(bloc, roiData);
    //
  }
}
