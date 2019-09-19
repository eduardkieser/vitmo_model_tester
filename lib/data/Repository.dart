import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
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
        // id: maps[i]['id'],
        timeStamp: maps[i]['timeStamp'],
        value: maps[i]['value'],
        label: maps[i]['label'],
        certainty: maps[i]['certainty'],
      );
    });
  }

  Future<Map<String,VitmoSignal>> getParsedEntries()async{
    print('reading entries');
  List<Entry> entriesList = await getEntries();
  print('len of entries: ${entriesList.length}');
    Map<String,VitmoSignal> signalsMap = {};
    entriesList.forEach((entry){
      if (signalsMap.containsKey(entry.label)){
        signalsMap[entry.label].values.add(entry.value);
        signalsMap[entry.label].timeStamps.add(entry.timeStamp);
        signalsMap[entry.label].certainty.add(entry.certainty);
      }else{
        signalsMap[entry.label] = VitmoSignal(
          values: [entry.value],
          certainty: [entry.certainty],
          label: entry.label,
          timeStamps: [entry.timeStamp]
        );
      }
    });
    if (signalsMap.length==0){
      return null;
    }else{
      return signalsMap;
      }
  }

  Future<void> purgeRepository()async{
    final Database db = await getDataBase();
    await db.delete(
    'entries',
  );
  }

Future<Map<String,List<VitmoEntry>>> getParsedEntriesList()async{
    print('reading entries');
  List<Entry> entriesList = await getEntries();
  print('len of entries: ${entriesList.length}');
    Map<String,List<VitmoEntry>> signalsMap = {};
    entriesList.forEach((entry){
      if (signalsMap.containsKey(entry.label)){
        signalsMap[entry.label].add(VitmoEntry(
          label: entry.label,
          value: entry.value,
          certainty: entry.certainty,
          timeStamp: entry.timeStamp
        ));
      }else{
        signalsMap[entry.label] = [VitmoEntry(
          label: entry.label,
          value: entry.value,
          certainty: entry.certainty,
          timeStamp: entry.timeStamp
        )];
      }
    });
    if (signalsMap.length==0){
      return null;
    }else{
      return signalsMap;
      }
  }
}

class VitmoSignal{
  List<int> values;
  List<int> timeStamps;
  List<double> certainty;
  String label;
  VitmoSignal({this.values,this.label, this.certainty, this.timeStamps});
}

class VitmoEntry{
  int value;
  int timeStamp;
  double certainty;
  String label;
  VitmoEntry({this.timeStamp,this.label,this.certainty,this.value});
}