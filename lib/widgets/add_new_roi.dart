import 'package:flutter/material.dart';
import 'package:vitmo_model_tester/blocks/MultiFrameBlock.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

class AddNewFrame extends StatefulWidget {
  AddNewFrame({Key key, this.bloc}) : super(key: key);

  final MultiFrameBlock bloc;

  @override
  _AddNewFrameState createState() => _AddNewFrameState();
}

class _AddNewFrameState extends State<AddNewFrame> {
  bool isMMM = false;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
    widget.bloc.toggleIsAdding(); // Do some stuff.
    return true;
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  Widget _buildDropDownLabelsList() {
    List<String> labelOptions = ['HR', 'ABP', 'SpO2', 'Temp', 'RespRate'];
    List dropDownItems =
        labelOptions.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();

    return DropdownButton<String>(
        hint: Text('Please select label'),
        value: widget.bloc.frameAddingWidgetCurrentLabel,
        onChanged: (String newValue) {
          widget.bloc.frameAddingWidgetCurrentLabel = newValue;
          widget.bloc.isAddingNewFrameStreamController.add(true);
          // bloc.frameController.add(bloc);
          print('chose new value $newValue');
        },
        items: dropDownItems);
  }

  Widget _buildMmmVNormalSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        FlatButton(
          color: isMMM ? Colors.transparent : Colors.blue,
          onPressed: () {
            setState(() {
              isMMM = false;
            });
          },
          child: Text('Normal Frame'),
        ),
        FlatButton(
          color: isMMM ? Colors.blue : Colors.transparent,
          onPressed: () {
            setState(() {
              isMMM = true;
            });
          },
          child: Text('Min/Max (Mean)'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    num border = 20.0;
    return Positioned(
      top: border,
      bottom: border,
      left: border,
      right: border,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(15.0)),
        child: ListView(padding: EdgeInsets.all(50), children: <Widget>[
          _buildMmmVNormalSelector(),
          _buildDropDownLabelsList(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  widget.bloc.addNewFrame(isMMM);
                },
                child: Text('AddFrame'),
              ),
              FlatButton(
                onPressed: () {
                  widget.bloc.toggleIsAdding();
                },
                child: Text('Cancel'),
              ),
            ],
          )
        ]),
      ),
    );
  }
}
