import 'package:flutter/material.dart';
import 'package:vitmo_model_tester/blocks/LiveTestBlock.dart';
import 'package:camera/camera.dart';
import 'dart:async';


class LiveTestScreen extends StatefulWidget {
  // CameraDescription firstCamera;
  LiveTestScreen({Key key}) : super(key: key);
  _LiveTestScreenState createState() => _LiveTestScreenState();
}

class _LiveTestScreenState extends State<LiveTestScreen> {
  LiveTestBlock _bloc = LiveTestBlock();

  @override
  initState() {
    super.initState();
    _bloc.prepCamera();
    print('all good to go');
  }

  _buildPreviewWindow() {
    return StreamBuilder(
        stream: _bloc.cameraIsInitializedStreamController.stream,
        initialData: false,
        builder: (context, snapshot) {
          if (snapshot.data) {
            double _previewWidth = MediaQuery.of(context).size.width;
            _previewWidth = _previewWidth/2;
            double _previewHeight =
                _previewWidth / _bloc.cameraController.value.aspectRatio;
            return Center(
              child: Container(
                  alignment: Alignment.center,
                  width: _previewWidth,
                  height: _previewHeight,
                  child: CameraPreview(_bloc.cameraController)),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget _returnButton() {
    return FlatButton(
      child: Text('Return to Static Test'),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[_returnButton(), _buildPreviewWindow()],
      ),
    );
  }
}
