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

  

  Widget _buildFloatingMenu(bloc){
    var _fabMiniMenuItemList = [
    
    FabMiniMenuItem.withText(
       Icon(Icons.settings),
       Colors.blue,
       4.0,
       "show settings menue",
       bloc.toggleShowSettings,
       "show settings menue",
       Colors.blue,
       Colors.white,
      ),

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
       Icon(Icons.play_arrow),
       Colors.blue,
       4.0,
       "Starts the frame capturing",
       bloc.startImageStream,
       "start recording",
       Colors.blue,
       Colors.white,
      ),
    ];
    bool hideAfterSelect = false;
    return FabDialer(_fabMiniMenuItemList, Colors.blue, Icon(Icons.add), Icon(Icons.close), 250, hideAfterSelect);
  }

  // _buildFloatingMenueFromStream(bloc){
  //   // return Container();
  //   return StreamBuilder(
  //     stream: bloc.frameController.stream,
  //     initialData: bloc,
  //     builder: (context, snapshot){
  //       return _buildFloatingMenu(bloc);
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    @override
    dispose(){
      widget.bloc.dispose();
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    return Scaffold(
      body: ZoomAndPanStack(bloc:widget.bloc),
      // floatingActionButton: _buildFloatingMenueFromStream(widget.bloc)
    );
  }
}