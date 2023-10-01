import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:sample_generator/service/enums/watermark_position.dart';
import 'package:sample_generator/service/exceptions/detailed_exception.dart';

class ImageEditor {
  String? watermarkPath = "assets/watermark.png";
  String? inputFolderPath;
  String? outputDirectory;
  double scale = 10;
  double watermarkScale = 1;
  img.Image? watermark;
  WatermarkPosition watermarkPosition = WatermarkPosition.center;
  int quality = 50;
  late final void Function(double?)? callback;

  Future<void> applyWatermarkToDirectory() async {
    _setup();
    if (watermark == null || inputFolderPath == null || outputDirectory == null) {
      return;
    }
    List<File> imagesInDir = _filterNonImages(Directory(inputFolderPath!).listSync());
    int count = 0;
    for (File file in imagesInDir) {
      if (path.extension(file.path).isEmpty) continue;
      String imageName = path.basename(file.path);
      if (imageName.contains("watermark")) {
        continue;
      }
      final outputFile = File(path.join(outputDirectory!, imageName));

      img.Image? image = img.decodeImage(await file.readAsBytes());
      if (image != null) {
        var editedImage = _applyWatermarkToFile(image);
        if (editedImage != null) {
          await outputFile.writeAsBytes(img.encodeJpg(editedImage));
          if (callback != null) {
            callback!((++count/imagesInDir.length * 100));
          }
        }
      }
    }
  }

  void _setup() {
    _validateDirectories();
    img.Image? temp = img.decodeImage(File(watermarkPath!).readAsBytesSync());
    if (temp != null) {
      watermark =  img.copyResize(temp,
        width: temp.width ~/ watermarkScale,
        height: temp.height ~/ watermarkScale,
        interpolation: img.Interpolation.cubic
      );
    } else {
      throw DetailedException("Failed to open watermark", "Failed to open watermark. Please check that the file is valid");
    }
  }

  void _validateDirectories() {
    if (watermarkPath == null || inputFolderPath == null || outputDirectory == null) {
      throw DetailedException(
          "The provided directory/ies are invalid.",
          "Watermark: $watermarkPath\nInput Image Folder: $inputFolderPath \nOutput Folder: $outputDirectory");
    }
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

