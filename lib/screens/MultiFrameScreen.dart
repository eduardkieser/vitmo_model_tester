import 'package:flutter/material.dart';
import 'package:vitmo_model_tester/blocks/MultiFrameBlock.dart';
import 'package:vitmo_model_tester/widgets/zoom_and_pan_stack.dart';
import 'package:fab_dialer/fab_dialer.dart';
import 'package:vitmo_model_tester/screens/SignalsScreen.dart';
import 'package:vitmo_model_tester/blocks/SignalsBloc.dart';

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

  showCharts(){
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => TimeTrace(bloc:SignalsBloc())),
  );
  }

  Widget _buildFloatingMenu(bloc){
    var _fabMiniMenuItemList = [
    FabMiniMenuItem.withText(
       Icon(Icons.add),
       Colors.blue,
       4.0,
       "Adds a new roi window.",
       bloc.toggleIsAdding,
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
      FabMiniMenuItem.withText(
       Icon(Icons.show_chart),
       Colors.blue,
       4.0,
       "Show charts",
       showCharts,
       "show charts",
       Colors.blue,
       Colors.white,
      ),
      FabMiniMenuItem.withText(
       Icon(Icons.delete),
       Colors.blue,
       4.0,
       "Purge Database",
       bloc.repository.purgeRepository,
       "delete data",
       Colors.blue,
       Colors.white,
      ),
      FabMiniMenuItem.withText(
       Icon(Icons.image),
       Colors.blue,
       4.0,
       "Show Images",
       bloc.toggleShowRawImages,
       "show raw images",
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