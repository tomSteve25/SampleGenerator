import 'package:image/image.dart' as img;
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:sample_generator/WatermarkPositionEnum.dart';



class ImageEditor {
  String? watermarkPath = "assets/watermark.png";
  String? inputFolderPath;
  String? outputDirectory;
  int scale = 10;
  img.Image? watermark;
  WatermarkPosition watermarkPosition = WatermarkPosition.center;
  int quality = 50;

  void applyWatermarkToDirectory() {
    _setup();
    if (watermark == null || inputFolderPath == null || outputDirectory == null) {
      return;
    }
    List<File> imagesInDir = _filterNonImages(Directory(inputFolderPath!).listSync());
    for (File file in imagesInDir) {
      if (path.extension(file.path).isEmpty) continue;
      String imageName = path.basename(file.path);
      if (imageName.contains("watermark")) {
        continue;
      }
      final outputFile = File(path.join(outputDirectory!, imageName));

      img.Image? image = img.decodeImage(file.readAsBytesSync());
      if (image != null) {
        var editedImage = _applyWatermarkToFile(image);
        if (editedImage != null) {
          outputFile.writeAsBytesSync(img.encodeJpg(editedImage));
        }
      }
    }
  }

  void _setup() {
    watermark = img.decodeImage(File(watermarkPath!).readAsBytesSync());
  }

  img.Image? _applyWatermarkToFile(img.Image image) {
    img.Image? resizedImage = _resizeImage(image);
    if (resizedImage != null) {
      var (posX, posY) = _determineWatermarkPosition(resizedImage.height, resizedImage.width);
      resizedImage = img.drawImage(resizedImage, watermark!, dstX: posX, dstY: posY);
    }
    return resizedImage;
  }

  img.Image? _resizeImage(img.Image orig) {
    img.Image resizedImage = img.copyResize(orig,
        width: orig.width ~/ scale,
        height: orig.height ~/ scale,
        interpolation: img.Interpolation.cubic);
    return img.decodeImage(img.encodeJpg(resizedImage, quality: quality));
  }

  (int, int) _determineWatermarkPosition(int imageHeight, int imageWidth) {
    int posX, posY;
    switch (watermarkPosition) {
      case WatermarkPosition.topLeft:
        posX = 0;
        posY = 0;
        break;
      case WatermarkPosition.topRight:
        posX = imageWidth - watermark!.width;
        posY = 0;
        break;
      case WatermarkPosition.bottomLeft:
        posX = 0;
        posY = imageHeight - watermark!.height;
        break;
      case WatermarkPosition.bottomRight:
        posX = imageWidth - watermark!.width;
        posY = imageHeight - watermark!.height;
        break;
      case WatermarkPosition.center:
        posX = imageWidth ~/ 2 - watermark!.width ~/ 2;
        posY = imageHeight ~/ 2 - watermark!.height ~/ 2;
        break;
    }
    return (posX, posY);
  }

  bool isImageFile(FileSystemEntity file) {
    List<String> validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp'];
    return validExtensions.contains(path.extension(file.uri.pathSegments.last).toLowerCase());
  }

  List<File> _filterNonImages(List<FileSystemEntity> dirs) {
    return dirs.whereType<File>().where(isImageFile).toList();
  }

}

