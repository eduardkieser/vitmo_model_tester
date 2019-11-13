import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:vitmo_model_tester/blocks/MultiFrameBlock.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:vitmo_model_tester/screens/SignalsScreen.dart';
import 'package:vitmo_model_tester/blocks/SignalsBloc.dart';

class MultiFrameSettings extends StatefulWidget {
  MultiFrameBlock _bloc;
  MultiFrameSettings(this._bloc);
  @override
  _MultiFrameSettingsState createState() => _MultiFrameSettingsState();
}

class _MultiFrameSettingsState extends State<MultiFrameSettings> {
  Color _iconColorOn = Colors.blue;
  Color _iconColorOff = Colors.grey;

  @override
  void initState() { 
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }
  bool myInterceptor(bool stopDefaultButtonEvent) {
    widget._bloc.toggleShowSettings(); // Do some stuff.
    return true;
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  showCharts() {
    // BackButtonInterceptor.remove(myInterceptor);
    Navigator.push(
      context,
      // MaterialPageRoute(builder: (context) => EntriesLineChart.fromEntriesList(widget.bloc.) ),
      MaterialPageRoute(builder: (context) => TimeTrace(bloc: SignalsBloc())),
      // MaterialPageRoute(builder: (context) => SimpleTimeSeriesChart.withSampleData()),
    );
  }

  Widget _flipButton() {
    return Card(
      child: ListTile(
        leading: Icon(Icons.swap_vert,
            color: widget._bloc.isUpsideDown ? _iconColorOn : _iconColorOff),
        title: Text('Flip Upside Down'),
        subtitle: Text('Flip the screen to use upside down.'),
        trailing: Switch(
          value: widget._bloc.isUpsideDown,
          onChanged: (bool newValue) {
            widget._bloc.flipScreen();
          },
        ),
      ),
    );
  }

  Widget _toggleDemoMode() {
    return Card(
      child: ListTile(
        leading: Icon(Icons.developer_mode,
            color: widget._bloc.isDemoMode ? _iconColorOn : _iconColorOff),
        title: Text('Show Demo Mode'),
        subtitle: Text('Use demonstration mode.'),
        trailing: Switch(
          value: widget._bloc.isDemoMode,
          onChanged: (bool newValue) {
            widget._bloc.toggleDemoMode();
          },
        ),
      ),
    );
  }

  Widget _showRawImages() {
    return Card(
      child: ListTile(
        leading: Icon(Icons.image,
            color: widget._bloc.showActualCroppedFrames
                ? _iconColorOn
                : _iconColorOff),
        title: Text('Show Raw Images'),
        subtitle: Text('Show raw images inside frame'),
        trailing: Switch(
          value: widget._bloc.showActualCroppedFrames,
          onChanged: (bool newValue) {
            widget._bloc.toggleShowRawImages();
          },
        ),
      ),
    );
  }

  Widget _invertColors() {
    return Card(
      child: ListTile(
        leading: Icon(Icons.invert_colors,
            color: widget._bloc.invertColors ? _iconColorOn : _iconColorOff),
        title: Text('Inver Colors'),
        subtitle: Text('Invert image colors (for dark backgrounds)'),
        trailing: Switch(
          value: widget._bloc.invertColors,
          onChanged: (bool newValue) {
            widget._bloc.toggleInvertImageColors();
          },
        ),
      ),
    );
  }

  Widget _showCharts() {
    return Card(
      child: ListTile(
        leading: Icon(Icons.show_chart, color: _iconColorOn),
        title: Text('Show Carts'),
        subtitle: Text('Show chart of patient vitals.'),
        onTap: () {
          widget._bloc.toggleShowSettings();
          showCharts();
        },
      ),
    );
  }

  Widget _clearData() {
    return Card(
      child: ListTile(
        leading: Icon(Icons.delete, color: _iconColorOn),
        title: Text('Clear Data'),
        subtitle: Text('Delete all data'),
        onTap: () {
          widget._bloc.repository.purgeRepository();
        },
      ),
    );
  }

  Widget _uploadData() {
    return Card(
      child: ListTile(
        leading: Icon(Icons.file_upload, color: _iconColorOn),
        title: Text('Upload Data'),
        subtitle: Text('Send data as email'),
        onTap: () {
          widget._bloc.toggleShowSettings();
          widget._bloc.repository.sendDataAsEmail();
        },
      ),
    );
  }

    Widget _returnToMain() {
    return Card(
      child: ListTile(
        leading: Icon(Icons.done, color: _iconColorOn),
        title: Text('Done'),
        subtitle: Text('Go back to main screen'),
        onTap: () {
          widget._bloc.toggleShowSettings();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.all(0),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: Colors.white70),
          child: ListView(
            padding: EdgeInsets.all(20),
            children: <Widget>[
              _flipButton(),
              _toggleDemoMode(),
              _showRawImages(),
              _invertColors(),
              _showCharts(),
              _uploadData(),
              _clearData(),
              _returnToMain()
            ],
          ),
        ),
      ),
    );
  }
}
