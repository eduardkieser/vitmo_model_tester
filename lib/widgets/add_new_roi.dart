import 'package:flutter/material.dart';
import 'package:vitmo_model_tester/blocks/MultiFrameBlock.dart';

class AddNewFrame extends StatelessWidget {
  AddNewFrame({Key key, this.bloc}) : super(key: key);

  final MultiFrameBlock bloc;

  Widget _buildDropDownLabelsList() {
    List dropDownItems = <String>['HR', 'ABP', 'SpO2', 'Temp', 'RespRate']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList();

    return DropdownButton<String>(
        hint: Text('Please select label'),
        value: bloc.frameAddingWidgetCurrentLabel,
        onChanged: (String newValue) {
          bloc.frameAddingWidgetCurrentLabel=newValue;
          bloc.isAddingNewFrameStreamController.add(true);
          // bloc.frameController.add(bloc);
          print('chose new value $newValue');
        },
        items: dropDownItems);
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
        child: ListView(
          padding: EdgeInsets.all(50),
          children: <Widget>[
          _buildDropDownLabelsList(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  bloc.addNewFrame();
                },
                child: Text('AddFrame'),
              ),
              FlatButton(
                onPressed: () {
                  bloc.toggleIsAdding();
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
