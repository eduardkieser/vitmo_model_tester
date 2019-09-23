import 'package:flutter/material.dart';
import 'package:vitmo_model_tester/data/Repository.dart';
import 'package:vitmo_model_tester/data/entry_model.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class EntriesLineChart extends StatelessWidget {
  // final Map<String,List<VitmoEntry>> entriesMap;
  final List<charts.Series> seriesList;
  const EntriesLineChart({Key key,this.seriesList});

  factory EntriesLineChart.withSampleData(){
    return EntriesLineChart(seriesList: _createSampleData());
  }

  factory EntriesLineChart.fromEntriesList(List<VitmoEntry> entriesList){
    return EntriesLineChart(seriesList: _parseEntriesList(entriesList));
  }

  static List<charts.Series<VitmoEntry, DateTime>> _parseEntriesList(List<VitmoEntry> entriesList) {
    return [
      new charts.Series<VitmoEntry, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (VitmoEntry entry, _) => entry.timeStamp,
        measureFn: (VitmoEntry entry, _) => entry.value,
        data: entriesList,
      )
    ];
  }

  static List<charts.Series<VitmoEntry, DateTime>> _createSampleData() {
    final data = [
      new VitmoEntry(timeStamp: DateTime.fromMillisecondsSinceEpoch(1568937600000), label: 'derp',certainty: .99,value: 12),
      new VitmoEntry(timeStamp: DateTime.fromMillisecondsSinceEpoch(1568938600000), label: 'derp',certainty: .99,value: 14),
      new VitmoEntry(timeStamp: DateTime.fromMillisecondsSinceEpoch(1568939600000), label: 'derp',certainty: .99,value: 12),
      new VitmoEntry(timeStamp: DateTime.fromMillisecondsSinceEpoch(1568940600000), label: 'derp',certainty: .99,value: 14),
      new VitmoEntry(timeStamp: DateTime.fromMillisecondsSinceEpoch(1568950600000), label: 'derp',certainty: .99,value: 14),
    ];

    return [
      new charts.Series<VitmoEntry, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (VitmoEntry entry, _) => entry.timeStamp,
        measureFn: (VitmoEntry entry, _) => entry.value,
        data: data,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {

    return new charts.TimeSeriesChart(
      seriesList,
      animate: true,
      // Optionally pass in a [DateTimeFactory] used by the chart. The factory
      // should create the same type of [DateTime] as the data provided. If none
      // specified, the default creates local date time.
      dateTimeFactory: const charts.LocalDateTimeFactory(),
      
    );

  }
}