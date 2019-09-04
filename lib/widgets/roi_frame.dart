import 'package:flutter/material.dart';
import 'dart:math';
import 'package:vitmo_model_tester/blocks/MultiFrameBlock.dart';

import '../models/roi_frame_model.dart';

class RoiFrame extends StatelessWidget {
  final MultiFrameBlock bloc;
  final int frameIndex;
  RoiFrame({this.bloc, this.frameIndex});

  void moveFirstTag({DragUpdateDetails details}){
    bloc.moveFirstTag(details,frameIndex);
  }

  void moveSecondTag({DragUpdateDetails details}){
    bloc.moveSecondTag(details,frameIndex);
  }

  void moveFrame({DragUpdateDetails details}) {
    bloc.moveFrame(details,frameIndex);
  }

  void selectFrame(){//appState is called for when the order starts to matter.
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
        onPanDown: (DragDownDetails details){
          selectFrame();
        },
        onPanUpdate: (DragUpdateDetails details) {
          moveFirstTag(details:details);
        },
        child: Container(
          color: Colors.blue,
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
        onPanDown: (DragDownDetails details){
          selectFrame();
        },
        onPanUpdate: (DragUpdateDetails details) {
          moveSecondTag(details:details);
        },
        child: Container(
          color: Colors.blue,
          child:
              Center(child: Text(bloc.frames[frameIndex].recognisedLabel.toString())),
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
    return Positioned(
      top: _top,
      left: _left,
      width: _width,
      height: _height,
      child: GestureDetector(
          onPanDown: (DragDownDetails details){
            selectFrame();
          },
          onPanUpdate: (DragUpdateDetails details) {
            moveFrame(details: details);
          },
          child: Stack(
              children: <Widget>[
                // appState.thumbsForDisplay.length>frameIndex? appState.thumbsForDisplay[frameIndex]['img']:
                Container(color: bloc.selectedFrameIndex==this.frameIndex?
                  Colors.white.withAlpha(100):
                  Colors.white.withAlpha(50)),
                  Center(child:Text("label: ${bloc.frames[frameIndex].currentValue} \n cartainty:${bloc.frames[frameIndex].certainty.toStringAsFixed(2)}"))
              ])),
    );
  }

  Widget _buildFrame(MultiFrameBlock bloc) {
    return Stack(children: <Widget>[
      _buildBorder(bloc),
      _buildFirstTag(bloc),
      _buildSecondTag(bloc),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return _buildFrame(bloc);
    //
  }
}
