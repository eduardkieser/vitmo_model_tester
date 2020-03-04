import 'dart:async';

import 'package:vitmo_model_tester/data/Repository.dart';

class SignalsBloc {
  Timer readerTimer;
  Repository repository = Repository();

  StreamController<Map<String, List<VitmoEntry>>>
      signalsUpdateStreamController = StreamController();

  startRepositoryReader() async {
    readerTimer = Timer.periodic(Duration(seconds: 1), (Timer t) async {
      Map<String, List<VitmoEntry>> parsedSignals =
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
