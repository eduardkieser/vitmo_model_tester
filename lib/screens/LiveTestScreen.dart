import 'package:flutter/material.dart';
import 'package:vitmo_model_tester/blocks/LiveTestBlock.dart';
import 'package:camera/camera.dart';
import 'dart:async';


class LiveTestScreen extends StatefulWidget {
  // CameraDescription firstCamera;
  LiveTestBlock bloc;
  LiveTestScreen({Key key, this.bloc}) : super(key: key);
  _LiveTestScreenState createState() => _LiveTestScreenState();
}

class _LiveTestScreenState extends State<LiveTestScreen> {
  

  @override
  initState() {
    super.initState();
    widget.bloc;
    widget.bloc.prepCamera();
    // _bloc.prepModel();
    print('all good to go');
    widget.bloc.setupListeners();
  }

  _buildPreviewWindow() {
    return StreamBuilder(
        stream: widget.bloc.cameraIsInitializedStreamController.stream,
        initialData: false,
        builder: (context, snapshot) {
          if (snapshot.data) {
            double _previewWidth = MediaQuery.of(context).size.width;
            _previewWidth = _previewWidth/2;
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

  Widget _results(){
    return StreamBuilder(
      stream: widget.bloc.resultStreamController.stream,
      initialData: ['NaN','NaN'],
      builder: (context,snapshot){
        return Container(
          alignment: Alignment.center,
          child: Text('Label: ${snapshot.data[0]} \n Certainty: ${snapshot.data[1]}'),
          );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          _returnButton(),
          _buildPreviewWindow(),
          _startImageStream(),
          _stopImageStream(),
          _results()
          ],
      ),
    );
  }
}
