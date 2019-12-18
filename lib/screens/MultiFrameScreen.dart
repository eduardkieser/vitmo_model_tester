import 'package:flutter/material.dart';
import 'package:vitmo_model_tester/blocks/MultiFrameBlock.dart';
import 'package:vitmo_model_tester/widgets/zoom_and_pan_stack.dart';
import 'package:fab_dialer/fab_dialer.dart';
import 'package:flutter/services.dart';

class MultiFrameScreen extends StatefulWidget {
  final MultiFrameBlock bloc;
  MultiFrameScreen({Key key, this.bloc}) : super(key: key);

  _MultiFrameScreenState createState() => _MultiFrameScreenState();
}

class _MultiFrameScreenState extends State<MultiFrameScreen> {

  @override void initState() {
    super.initState();
    widget.bloc.prepCamera();
    widget.bloc.addListeners();
  }

    @override
    void dispose(){
      widget.bloc.dispose();
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ZoomAndPanStack(bloc:widget.bloc),
    );
  }
}