import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';
import 'dart:ui';

import 'package:vitmo_model_tester/models/roi_frame_model.dart';


class ImageConverter{

  static Future<imglib.Image> convertYUV420toImageFast(
      CameraImage image) async {
    try {
      final int width = image.width;
      final int height = image.height;

      // imglib -> Image package from https://pub.dartlang.org/packages/image
      var img = imglib.Image(width, height); // Create Image buffer

      Plane plane = image.planes[0];
      const int shift = (0xFF << 24);

      // Fill image buffer with plane[0] from YUV420_888
      for (int x = 0; x < width; x++) {
        for (int planeOffset = 0; planeOffset < height * width; planeOffset += width) {
          final pixelColor = plane.bytes[planeOffset + x];
          // color: 0x FF  FF  FF  FF
          //           A   B   G   R
          // Calculate pixel color
          var newVal =
              shift | (pixelColor << 16) | (pixelColor << 8) | pixelColor;
          img.data[planeOffset + x] = newVal;
        }
      }

      return img;
    } catch (e) {
      print(">>>>>>>>>>>> ERROR:" + e.toString());
    }
    return null;
  }

  static Future<List<int>> convertYUV420toImage(CameraImage image) async {

      try {
        final int width = image.width;
        final int height = image.height;

        
        // imgLib -> Image package from https://pub.dartlang.org/packages/image
        var img = imglib.Image(width, height); // Create Image buffer

        // Fill image buffer with plane[0] from YUV420_888
        for(int x=0; x < width; x++) {
          for(int y=0; y < height; y++) {
            final pixelColor = image.planes[0].bytes[y * width + x];
            // color: 0x FF  FF  FF  FF 
            //           A   B   G   R
            // Calculate pixel color
            img.data[y * width + x] = (0xFF << 24) | (pixelColor << 16) | (pixelColor << 8) | pixelColor;
          }
        }

        imglib.PngEncoder pngEncoder = new imglib.PngEncoder(level: 0, filter: 0);
        List<int> png = pngEncoder.encodeImage(img);
        // muteYUVProcessing = false;
        return png;  
      } catch (e) {
        print(">>>>>>>>>>>> ERROR:" + e.toString());
      }
      return null;
  }

  static Future <imglib.Image> cropRotate(Map<String, dynamic> cropData)async{
      imglib.Image image = cropData['image'];
      image = imglib.copyRotate(image, 90);
      RoiFrameModel frame = cropData['frames'][0];
      List<num> screenSize = cropData['screenSize'];
      int x0 = (frame.firstCorner.dx/screenSize[0] * image.width).round();
      int y0 = (frame.firstCorner.dy/screenSize[1] * image.height).round();
      int x1 = (frame.secondCorner.dx/screenSize[0] * image.width).round();
      int y1 = (frame.secondCorner.dy/screenSize[1] * image.height).round();
      image = imglib.copyCrop(image, x0, y0, (x1-x0), (y1-y0));
      //image = imglib.copyCrop(image, image.width-x1, image.height-y1, (x1-x0), (y1-y0));
      image = imglib.copyResize(image, width:48, height:48);
      return image;
  }

    static Future<List<imglib.Image>> cropRotateSet(Map<String, dynamic> cropData)async{
      List<imglib.Image> images = [];
      List<num> screenSize = cropData['screenSize'];
      imglib.Image image = cropData['image'];
      image = imglib.copyRotate(image, 90);
      cropData['frames'].forEach((RoiFrameModel frame){
        int x0 = (frame.firstCorner.dx/screenSize[0] * image.width).round();
        int y0 = (frame.firstCorner.dy/screenSize[1] * image.height).round();
        int x1 = (frame.secondCorner.dx/screenSize[0] * image.width).round();
        int y1 = (frame.secondCorner.dy/screenSize[1] * image.height).round();
        imglib.Image imageOut = imglib.copyCrop(image, x0, y0, (x1-x0), (y1-y0));
        imageOut = imglib.copyResize(imageOut, width:48, height:48);
        images.add(imageOut);
      });
      return images;
  }

  static Future<List<int>> encodePng(imglib.Image image)async{
    imglib.PngEncoder pngEncoder = imglib.PngEncoder(level: 0, filter: 0);
    List<int> png = pngEncoder.encodeImage(image);
    return png;
  }

  static Future<imglib.Image> convertYUV420toImageColor(CameraImage image) async {
      try {
        final int width = image.width;
        final int height = image.height;
        final int uvRowStride = image.planes[1].bytesPerRow;
        final int uvPixelStride = image.planes[1].bytesPerPixel;

        print("uvRowStride: " + uvRowStride.toString());
        print("uvPixelStride: " + uvPixelStride.toString());
        
        // imgLib -> Image package from https://pub.dartlang.org/packages/image
        var img = imglib.Image(width, height); // Create Image buffer

        // Fill image buffer with plane[0] from YUV420_888
        for(int x=0; x < width; x++) {
          for(int y=0; y < height; y++) {
            final int uvIndex = uvPixelStride * (x/2).floor() + uvRowStride*(y/2).floor();
            final int index = y * width + x;

            final yp = image.planes[0].bytes[index];
            final up = image.planes[1].bytes[uvIndex];
            final vp = image.planes[2].bytes[uvIndex];
            // Calculate pixel color
            int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
            int g = (yp - up * 46549 / 131072 + 44 -vp * 93604 / 131072 + 91).round().clamp(0, 255);
            int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);     
            // color: 0x FF  FF  FF  FF 
            //           A   B   G   R
            img.data[index] = (0xFF << 24) | (b << 16) | (g << 8) | r;
          }
        }
        // muteYUVProcessing = false;
        // return Image.memory(png);  
        return img;
      } catch (e) {
        print(">>>>>>>>>>>> ERROR:" + e.toString());
      }
      return null;
  }

  static Future<CameraImage> cropCameraFrame(CameraImage image){

    final int width = image.width;
    final int height = image.height;
    final Offset topLeft = Offset(.25*width.floor(),.25*height.floor());
    final Offset bottomRight = Offset(.25*width.floor(),.25*height.floor());

  }

}