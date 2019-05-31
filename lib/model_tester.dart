import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:tflite/tflite.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'models/model_data.dart';
import 'package:vitmo_model_tester/blocks/StaticTestBlock.dart';

class DataBuilder {

  Future<Map<String, String>> getTestingData(
      {String folderName, int numPerClass}) async {
    Map<String, String> dataMap = Map();
    String rootDir = await getRootFolder(folderName);

    PermissionStatus _perStatus = await SimplePermissions.requestPermission(
        Permission.ReadExternalStorage);
    print(_perStatus.toString());
    // get a list of all the folders in the "numbers" directory
    List<FileSystemEntity> catList = Directory(rootDir).listSync();

    catList.asMap().forEach((i, catDir) {
      String catPath = catDir.path;
      String catName = basename(catPath);

      List<FileSystemEntity> imgList = Directory(catPath).listSync();

      if (imgList.length > numPerClass) {
        imgList = imgList.sublist(0, numPerClass);
      }

      imgList.forEach((imgDir) {
        String imgPath = imgDir.path;
        dataMap[imgPath] = catName;
      });
    });
    return dataMap;
  }

  Future<String> getRootFolder(String folderName) async {
    final directory = await getExternalStorageDirectory();
    return "${directory.path}/$folderName";
  }
}

class ModelPrepper {
  static prepModel({String model, String labels}) async {
    // prep model
    String res =
        await Tflite.loadModel(model: model, labels: labels, numThreads: 1);
    print('model loading status for $model ${res.toString()}');
  }
}

class ModelTester {
  Future<Map<String, String>> loadDataMap(
      {String folderName, int numPerClass}) async {
    Map<String, String> dataMap = await DataBuilder()
        .getTestingData(folderName: folderName, numPerClass: numPerClass);
    return dataMap;
  }

  testModelWithParams(
      {Map<String, String> dataMap,
      double imgStd,
      double imgMean,
      Stream<List<PerformanceData>> resultsStream,
      StaticTestBloc staticBlock
      }) async {
    int countTrue = 0;
    int countFalse = 0;
    int oneIfTrue = 0;
    print('#################### Loading model ###########################');
    print("#################### getting to the testing ##################");

    for (String imgPath in dataMap.keys) {
      String trueLabel = dataMap[imgPath];
      var recognitions = await Tflite.runModelOnImage(
          path: imgPath, // required
          imageMean: imgMean, // defaults to 117.0
          imageStd: imgStd, // defaults to 1.0
          numResults: 1, // defaults to 5
          threshold: 0.2, // defaults to 0.1
          asynch: true // defaults to true
          );

      if (recognitions.length > 0) {
        String result = recognitions[0]['label'];
        if (result == trueLabel) {
          countTrue++;
          oneIfTrue = 1;
        } else {
          countFalse++;
          oneIfTrue = 0;
        }

        staticBlock.addPerformaceSnapshot(
          [PerformanceData(
            countFalse: countFalse,
            coutTrue: countTrue,
            recognitionTime: 20,
            result: '20'
          )]
        );
        
      }

      print('accuracy = ${countTrue / (countTrue + countFalse)}');
      // break;
    }
  }

  

  startTestBatch(ModelData testSetup, StaticTestBloc _block) async {
    Map<String, String> dataMap =
        await loadDataMap(folderName: testSetup.dataPath, numPerClass: 1);

    await ModelPrepper.prepModel(
        model: testSetup.model, labels: testSetup.labels);

    testModelWithParams(
        dataMap: dataMap, imgStd: testSetup.imgStd, imgMean: testSetup.imgMean,
        staticBlock:_block);
  }
}
