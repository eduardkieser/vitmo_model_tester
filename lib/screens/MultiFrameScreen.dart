import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:vitmo_model_tester/blocks/LiveTestBlock.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'package:image/image.dart' as imglib;
import 'package:vitmo_model_tester/blocks/MultiFrameBlock.dart';
import 'package:vitmo_model_tester/widgets/roi_frame.dart';
import 'package:vitmo_model_tester/widgets/zoom_and_pan_stack.dart';
import 'package:fab_dialer/fab_dialer.dart';


class MultiFrameScreen extends StatefulWidget {
  MultiFrameBlock bloc;
  MultiFrameScreen({Key key, this.bloc}) : super(key: key);

  _MultiFrameScreenState createState() => _MultiFrameScreenState();
}

class _MultiFrameScreenState extends State<MultiFrameScreen> {

  @override void initState() {
    super.initState();
    widget.bloc.prepCamera();
    widget.bloc.addListeners();
  }

  Widget _buildFloatingMenu(bloc){
    var _fabMiniMenuItemList = [
    FabMiniMenuItem.withText(
       Icon(Icons.add),
       Colors.blue,
       4.0,
       "Adds a new roi window.",
       bloc.addNewFrame,
       "add frame",
       Colors.blue,
       Colors.white,
      ),
    FabMiniMenuItem.withText(
       Icon(Icons.delete),
       Colors.blue,
       4.0,
       "Removes selected rio frame.",
       bloc.removeSelectedFrame,
       "remove selected frame",
       Colors.blue,
       Colors.white,
      ),
    FabMiniMenuItem.withText(
       Icon(Icons.play_arrow),
       Colors.blue,
       4.0,
       "Starts the frame capturing",
       bloc.startImageStream,
       "start recording",
       Colors.blue,
       Colors.white,
      ),
      FabMiniMenuItem.withText(
       Icon(Icons.stop),
       Colors.blue,
       4.0,
       "Stops the frame capturing",
       bloc.stopImageStream,
       "stop recording",
       Colors.blue,
       Colors.white,
      ),
    ];
    return FabDialer(_fabMiniMenuItemList, Colors.blue, Icon(Icons.add), Icon(Icons.close), 250, true);
  }

  @override
  Widget build(BuildContext context) {
    @override
    dispose(){
      widget.bloc.dispose();
    }


    return Scaffold(
      body: ZoomAndPanStack(bloc:widget.bloc),
      floatingActionButton: _buildFloatingMenu(widget.bloc)
    );
  }
}