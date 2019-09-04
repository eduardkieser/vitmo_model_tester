import 'package:flutter/material.dart';
import 'package:vitmo_model_tester/model_tester.dart';
import 'package:vitmo_model_tester/models/model_data.dart';
import 'dart:async';
import 'package:tflite/tflite.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;
import 'dart:typed_data';

class ImageReader {
  ModelData model;
  ImageReader({this.model});

  Future readImageFromFrame(CameraImage img) async {
    var recognitions = await Tflite.runModelOnFrame(
        bytesList: img.planes.map((plane) {
          return plane.bytes;
        }).toList(), // required
        imageHeight: img.height,
        imageWidth: img.width,
        imageMean: model.imgMean, // defaults to 127.5
        imageStd: model.imgStd, // defaults to 127.5a
        rotation: 90, // defaults to 90, Android only
        numResults: 3, // defaults to 5
        threshold: 0.1, // defaults to 0.1
        asynch: true // defaults to true
        );
    // print(recognitions.toString());
    return recognitions;
  }

  readImageFromBinary(imglib.Image image) async {
    Uint8List binaryData = imageToByteListFloat32(
        image, model.imgSize, model.imgMean, model.imgStd);
        var recognitions = await Tflite.runModelOnBinary(
          binary: binaryData,
          numResults: 3,
          threshold: 0.1,
          asynch: true
        );
    print('Length${recognitions.length}');
    print(recognitions.toString());
    print(recognitions[0]['label']);
    print(recognitions[0]['confidence']);
    return recognitions;
  }

  Uint8List imageToByteListFloat32(
      imglib.Image image, int inputSize, double mean, double std) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (imglib.getRed(pixel) - mean) / std;
        buffer[pixelIndex++] = (imglib.getGreen(pixel) - mean) / std;
        buffer[pixelIndex++] = (imglib.getBlue(pixel) - mean) / std;
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  Uint8List imageToByteListUint8(imglib.Image image, int inputSize) {
    var convertedBytes = Uint8List(1 * inputSize * inputSize * 3);
    var buffer = Uint8List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = imglib.getRed(pixel);
        buffer[pixelIndex++] = imglib.getGreen(pixel);
        buffer[pixelIndex++] = imglib.getBlue(pixel);
      }
    }
    return convertedBytes.buffer.asUint8List();
  }
}
