import 'package:flutter/material.dart';
import 'package:vitmo_model_tester/blocks/SignalsBloc.dart';
import 'package:vitmo_model_tester/data/entry_model.dart';
import 'package:vitmo_model_tester/widgets/time_series_chart.dart';

class TimeTrace extends StatefulWidget {
  final SignalsBloc bloc;
  TimeTrace({Key key, this.bloc}) : super(key: key);

  _TimeTraceState createState() => _TimeTraceState();
}

class _TimeTraceState extends State<TimeTrace> {
  Map<String, List<Entry>> parsedEntries;

  @override
  void initState() {
    super.initState();
    widget.bloc.startRepositoryReader();
  }

  @override
  void dispose() {
    super.dispose();
    widget.bloc.dispose();
    widget.bloc.stopRepositoryReader();
  }

  buildLineChartWithTitle(List<Entry> entriesList, String title) {
    return Column(
      children: <Widget>[
        Center(child: Text(title)),
        Container(
          height: 150,
          child: EntriesLineChart.fromEntriesList(entriesList),
        )
      ],
    );
  }

  buildListOfCharts(Map<String, List<Entry>> entriesMap) {
    List<Widget> chartsList = [];
    entriesMap.forEach((k, v) {
      chartsList.add(buildLineChartWithTitle(v, k));
    });
    return ListView(children: chartsList);
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
            // get first element from Map
            var entriesMap = snapshot.data;
            // List<Entry> entriesList = entriesMap[entriesMap.keys.cast().toList()[0]];
            return buildListOfCharts(entriesMap);
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
