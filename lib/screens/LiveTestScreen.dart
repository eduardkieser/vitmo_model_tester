import 'package:flutter/material.dart';
import 'package:vitmo_model_tester/blocks/LiveTestBlock.dart';


class LiveTestScreen extends StatefulWidget {
  LiveTestScreen({Key key}) : super(key: key);

  _LiveTestScreenState createState() => _LiveTestScreenState();
}

class _LiveTestScreenState extends State<LiveTestScreen> {
  LiveTestBlock _bloc = LiveTestBlock();

  @override
  Widget build(BuildContext context) {
    return Container(
       child: Container(),
    );
  }
}