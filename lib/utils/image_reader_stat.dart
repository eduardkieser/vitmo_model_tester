import 'dart:async';

import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';

class ImageReader {
  static Future<String> readImageFromFrame(CameraImage img) async {
    var recognitions = await Tflite.runModelOnFrame(
        bytesList: img.planes.map((plane) {
          return plane.bytes;
        }).toList(), // required
        imageHeight: img.height,
        imageWidth: img.width,
        imageMean: 20, // defaults to 127.5
        imageStd: 20, // defaults to 127.5a
        rotation: 90, // defaults to 90, Android only
        numResults: 1, // defaults to 5
        threshold: 0.1, // defaults to 0.1
        asynch: true // defaults to true
        );
    return recognitions.toString();
  }
}
