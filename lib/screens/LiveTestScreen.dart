import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:vitmo_model_tester/blocks/LiveTestBlock.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'package:image/image.dart' as imglib;
import 'package:vitmo_model_tester/widgets/roi_frame_tester.dart';

class LiveTestScreen extends StatefulWidget {
  // CameraDescription firstCamera;
  LiveTestBlock bloc;
  LiveTestScreen({Key key, this.bloc}) : super(key: key);
  _LiveTestScreenState createState() => _LiveTestScreenState();
}

class roiFrame {
  Offset p0 = Offset(0, 0);
  Offset p1 = Offset(20, 20);
}

class _LiveTestScreenState extends State<LiveTestScreen> {
  bool cameraIsReady = false;


  @override
  dispose(){
    widget.bloc.cameraImageStreamController.close();
    widget.bloc.cameraIsInitializedStreamController.close();
    widget.bloc.convertedImageStreamController.close();
    widget.bloc.resultStreamController.close();
    widget.bloc.frameController.close();
  }

  @override
  initState() {
    super.initState();
    widget.bloc.prepCamera();
    // _bloc.prepModel();
    print('all good to go');
    // widget.bloc.setupListeners();
  }

  Widget _previewWithRoi() {
    return Stack(
      children: <Widget>[
        Positioned(
            child: StreamBuilder(
                stream: widget.bloc.cameraIsInitializedStreamController.stream,
                initialData: false,
                builder: (context, snapshot) {
                  if (snapshot.data) {
                    cameraIsReady = true;
                    double _previewWidth = MediaQuery.of(context).size.width;
                    double _previewHeight = _previewWidth /
                        widget.bloc.cameraController.value.aspectRatio;
                    return Center(
                      child: Container(
                          alignment: Alignment.center,
                          width: _previewWidth,
                          height: _previewHeight,
                          child: CameraPreview(widget.bloc.cameraController)),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                })),
        Positioned(
            child: StreamBuilder(
              stream: widget.bloc.cameraIsInitializedStreamController.stream,
              initialData: false,
              builder: (context,snapshot1){
                if (snapshot1.data){
                  return StreamBuilder(
                    stream: widget.bloc.frameController.stream,
                    initialData: widget.bloc,
                    builder: (context, snapshot) {
                      double _previewWidth = MediaQuery.of(context).size.width;
                      double _previewHeight = _previewWidth /
                          widget.bloc.cameraController.value.aspectRatio;
                      widget.bloc.setFrameSize(_previewWidth, _previewHeight);
                      return Container(
                        child: RoiFrame(block: widget.bloc),
                        width: _previewWidth,
                        height: _previewHeight,
                      );
                    },
                  );
                } else {return Center(child: CircularProgressIndicator());}
              },
            )
                )
      ],
    );
  }

  _buildPreviewWindow() {
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
                  child: CameraPreview(widget.bloc.cameraController)),
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

  Widget _startImageStream() {
    return FlatButton(
      child: Text('Start Image Stream'),
      onPressed: () {
        widget.bloc.startImageStream();
      },
    );
  }

  Widget _stopImageStream() {
    return FlatButton(
      child: Text('Stop Image Stream'),
      onPressed: () {
        widget.bloc.stopImageStream();
        print('streaming stopped');
      },
    );
  }

  Widget _results() {
    return StreamBuilder(
      stream: widget.bloc.resultStreamController.stream,
      initialData: ['NaN', 'NaN'],
      builder: (context, snapshot) {
        return Container(
          alignment: Alignment.center,
          child: Text(
              'Label: ${snapshot.data[0]} \n Certainty: ${snapshot.data[1]}'),
        );
      },
    );
  }

  Widget _croppedImage() {
    return StreamBuilder(
        stream: widget.bloc.convertedImageStreamController.stream,
        initialData: '',
        builder: (context, snapshot) {
          if (snapshot.data == '') {
            return Container();
          } else {
            Uint8List image = snapshot.data;
            return Container(
                child: Image.memory(
              image,
              width: 100,
              height: 100,
            ));
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          _returnButton(),
          _previewWithRoi(),
          _croppedImage(),
          _startImageStream(),
          _stopImageStream(),
          _results()
        ],
      ),
    );
  }
}
