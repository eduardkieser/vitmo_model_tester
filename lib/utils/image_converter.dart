import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';
import 'dart:ui';


class ImageConverter{


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
        // return Image.memory(png);  
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