import 'package:flutter/material.dart';
import 'dart:math';
import 'package:vitmo_model_tester/blocks/LiveTestBlock.dart';

import '../models/roi_frame_model.dart';

class RoiFrame extends StatelessWidget {
  final LiveTestBlock block;

  RoiFrame({this.block});

  void moveFirstTag({DragUpdateDetails details}) {
    block.moveFirstTag(details);
  }

  void moveSecondTag({DragUpdateDetails details}) {
    block.moveSecondTag(details);
  }

  void moveFrame({DragUpdateDetails details}) {
    block.moveFrame(details);
  }

  // void selectFrame(DragDownDetails details){//appState is called for when the order starts to matter.
  //     appState.selectFrame(frameIndex);
  // }

  Widget _buildFirstTag(LiveTestBlock block) {
    RoiFrameModel frameData = block.frames[0];
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
        // onPanDown: (DragDownDetails details){
        //   selectFrame(details, appState);
        // },
        onPanUpdate: (DragUpdateDetails details) {
          moveFirstTag(details: details);
        },
        child: Container(
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildSecondTag(LiveTestBlock block) {
    RoiFrameModel frameData = block.frames[0];
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
        // onPanDown: (DragDownDetails details){
        //   selectFrame(details, appState);
        // },
        onPanUpdate: (DragUpdateDetails details) {
          moveSecondTag(details: details);
        },
        child: Container(
          color: Colors.blue,
          child:
              Center(child: Text(block.frames[0].recognisedLabel.toString())),
        ),
      ),
    );
  }

  Widget _buildBorder(LiveTestBlock block) {
    RoiFrameModel frameData = block.frames[0];
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
          // onPanDown: (DragDownDetails details){
          //   selectFrame(details, appState);
          // },
          onPanUpdate: (DragUpdateDetails details) {
            moveFrame(details: details);
          },
          child: Stack(
              // color: Colors.white.withAlpha(100),
              children: <Widget>[
                // appState.thumbsForDisplay.length>frameIndex? appState.thumbsForDisplay[frameIndex]['img']:
                Container(color: Colors.white.withAlpha(100)),
                // Center(child:Text("label: ${appState.frames[frameIndex].recognisedLabel} \n cartainty:${appState.frames[frameIndex].certainty.toStringAsFixed(2)}"))
              ])),
    );
  }

  Widget _buildFrame(LiveTestBlock block) {
    return Stack(children: <Widget>[
      _buildBorder(block),
      _buildFirstTag(block),
      _buildSecondTag(block),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return _buildFrame(block);
    //
  }
}
