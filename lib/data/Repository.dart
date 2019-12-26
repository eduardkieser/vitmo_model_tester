import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pedantic/pedantic.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vitmo_model_tester/data/entry_model.dart';

class Repository {
  Future<Database> getDataBase() async {
    // Open the database and store the reference.
    final Future<Database> database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      join(await getDatabasesPath(), 'doggie_database.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          "CREATE TABLE entries(label TEXT, timeStamp INTEGER, value INTEGER, certainty REAL)",
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 2,
    );
    return database;
  }

  Future<void> insertEntry(Entry entry) async {
    final Database db = await getDataBase();
    await db.insert('entries', entry.toMap());
  }

  Future<List<Entry>> getEntries() async {
    final Database db = await getDataBase();
    final List<Map<String, dynamic>> maps = await db.query('entries');
    return List.generate(maps.length, (i) {
      return Entry(
        timeStamp: maps[i]['timeStamp'],
        value: maps[i]['value'],
        label: maps[i]['label'],
        certainty: maps[i]['certainty'],
      );
    });
  }

  Future<void> purgeRepository() async {
    final Database db = await getDataBase();
    await db.delete(
      'entries',
    );
  }

  Future<Map<String, List<Entry>>> getParsedEntriesList() async {
    //print('reading entries');
    List<Entry> entriesList = await getEntries();
    //print('len of entries: ${entriesList.length}');
    Map<String, List<Entry>> signalsMap = {};
    entriesList.forEach((entry) {
      if (signalsMap.containsKey(entry.label)) {
        signalsMap[entry.label].add(entry);
      } else {
        signalsMap[entry.label] = [entry];
      }
    });
    if (signalsMap.isEmpty) {
      return null;
    } else {
      return signalsMap;
    }
  }

  Future<List<List>> readListListFromRepo() async {
    Map<String, List<Entry>> parsedEntries = await getParsedEntriesList();
    List<DateTime> allTimeStamps = [];
    List<String> allColumns = [];
    if (parsedEntries == null) {
      return null;
    }
    parsedEntries.forEach((key, listEnty) {
      allColumns.add(key);
      listEnty.forEach((entry) {
        allTimeStamps.add(DateTime.fromMillisecondsSinceEpoch(entry.timeStamp));
      });
    });
    allColumns = allColumns.toSet().toList();
    allColumns = ['index', ...allColumns];
    allTimeStamps = allTimeStamps.toSet().toList();
    List<List> output = [allColumns];
    List<Entry> entries = await getEntries();
    for (DateTime dt in allTimeStamps) {
      List currentRow = List(allColumns.length);
      currentRow[0] = dt;
      for (int colIx = 0; colIx < allColumns.length; colIx++) {
        String column = allColumns[colIx];
        for (Entry entry in entries) {
          if (entry.label == column &&
              entry.timeStamp == dt.millisecondsSinceEpoch) {
            currentRow[colIx] = entry.value;
          }
        }
      }
      output.add(currentRow);
    }
    return output;
  }

  Future<String> getCsvFromRepo() async {
    List<List> lili = await readListListFromRepo();
    String csv = ListToCsvConverter().convert(lili);
    return csv;
  }

  void sendDataAsEmail() async {
    String csv = await getCsvFromRepo();
    Directory tempDir = await getTemporaryDirectory();
    String filename = '${tempDir.path}/VitmoData.csv';

    await File(filename).writeAsString(csv);
    print('created csv file');
    final MailOptions mailOptions = MailOptions(
      body: 'VitmoData is attached',
      subject: 'VitmoDataDump',
      recipients: ['eduard.kieser@gmail.com'],
      isHTML: false,
      bccRecipients: [],
      ccRecipients: [],
      attachments: [filename],
    );
    print('trying to send');
    unawaited(FlutterMailer.send(mailOptions));
    print('should be sent');
  }
}
