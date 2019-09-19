import 'package:flutter/material.dart';
import 'package:vitmo_model_tester/data/Repository.dart';
import 'package:vitmo_model_tester/data/entry_model.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class EntriesLineChart extends StatelessWidget {
  final Map<String,List<VitmoEntry>> entriesMap;
  const EntriesLineChart({Key key,this.entriesMap}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    List<VitmoEntry> signal = entriesMap[entriesMap.keys.cast().toList()[0]];

    var series = [
      charts.Series(
        id: 'Derp',
        domainFn: (VitmoEntry signal,_)=>signal.timeStamp,
        measureFn: (VitmoEntry signal,_)=>signal.value,
        data: signal,
        )
    ];

    var lineChart = charts.LineChart(
      series,
      animate: false,
      behaviors: [charts.PanAndZoomBehavior()],
      );
    return Container(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: lineChart,
        ),
    );
  }
}