import 'package:flutter/material.dart';
import 'package:vitmo_model_tester/data/Repository.dart';
import 'package:vitmo_model_tester/data/entry_model.dart';
import 'package:vitmo_model_tester/widgets/time_series_chart.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:vitmo_model_tester/blocks/SignalsBloc.dart';

class TimeTrace extends StatefulWidget {
  SignalsBloc bloc;
  TimeTrace({Key key, this.bloc}) : super(key: key);

  _TimeTraceState createState() => _TimeTraceState();
}

class _TimeTraceState extends State<TimeTrace> {
  Map<String, List<VitmoEntry>> parsedEntries;

  @override
  void initState() {
    super.initState();
    widget.bloc.startRepositoryReader();
  }

  @override void dispose() {
    super.dispose();
    widget.bloc.dispose();
    widget.bloc.stopRepositoryReader();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
      body: Center(
          child: StreamBuilder(
        initialData: null,
        stream: widget.bloc.signalsUpdateStreamController.stream,
        builder: ((context, snapshot) {
          if (snapshot.data != null) {
            return EntriesLineChart(
              entriesMap: snapshot.data,
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        }),
      )),
    ));
  }
}
