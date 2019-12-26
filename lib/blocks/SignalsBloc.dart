import 'dart:async';

import 'package:vitmo_model_tester/data/entry_model.dart';
import 'package:vitmo_model_tester/data/Repository.dart';

class SignalsBloc {
  Timer readerTimer;
  Repository repository = Repository();

  StreamController<Map<String, List<Entry>>>
      signalsUpdateStreamController = StreamController();

  startRepositoryReader() async {
    readerTimer = Timer.periodic(Duration(seconds: 1), (Timer t) async {
      Map<String, List<Entry>> parsedSignals =
          await repository.getParsedEntriesList();
      signalsUpdateStreamController.sink.add(parsedSignals);
    });
  }

  stopRepositoryReader() {
    readerTimer.cancel();
  }

  dispose() {
    stopRepositoryReader();
    signalsUpdateStreamController.close();
  }
}
