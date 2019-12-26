import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:vitmo_model_tester/data/entry_model.dart';

class EntriesLineChart extends StatelessWidget {
  // final Map<String,List<VitmoEntry>> entriesMap;
  final List<charts.Series> seriesList;
  const EntriesLineChart({Key key, this.seriesList});

  // factory EntriesLineChart.withSampleData(){
  //   return EntriesLineChart(seriesList: _createSampleData());
  // }

  factory EntriesLineChart.fromEntriesList(List<Entry> entriesList) {
    return EntriesLineChart(seriesList: _parseEntriesList(entriesList));
  }

  static List<charts.Series<Entry, DateTime>> _parseEntriesList(
      List<Entry> entriesList) {
    return [
      charts.Series<Entry, DateTime>(
          id: 'Sales',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (Entry entry, _) => DateTime.fromMillisecondsSinceEpoch(entry.timeStamp),
          measureFn: (Entry entry, _) => entry.value,
          data: entriesList,
          measureLowerBoundFn: (Entry entry, _) => 0)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
      seriesList,
      animate: true,
      // Optionally pass in a [DateTimeFactory] used by the chart. The factory
      // should create the same type of [DateTime] as the data provided. If none
      // specified, the default creates local date time.
      dateTimeFactory: const charts.LocalDateTimeFactory(),
    );
  }
}
