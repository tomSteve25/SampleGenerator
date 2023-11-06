import 'dart:io';

import 'package:exif/exif.dart';
import 'package:image/image.dart' as img;
import 'package:image/image.dart';
import 'package:path/path.dart' as path;
import 'package:sample_generator/service/enums/watermark_position.dart';
import 'package:sample_generator/service/exceptions/detailed_exception.dart';

import 'enums/colours.dart';
import 'enums/font_size.dart';

class ImageEditor {
  String? watermarkPath = "assets/watermark.png";
  String? inputFolderPath;
  String? outputDirectory;
  double scale = 10;
  double watermarkScale = 1;
  img.Image? watermark;
  WatermarkPosition watermarkPosition = WatermarkPosition.center;
  int quality = 50;
  bool? textEnabled;
  Colour colour = Colour.black;
  FontSize fontSize = FontSize.medium;
  late final void Function(double?)? callback;

  Future<void> applyWatermarkToDirectory() async {
    await _setup();
    List<File> imagesInDir = _filterNonImages(Directory(inputFolderPath!).listSync());
    int count = 0;
    for (File file in imagesInDir) {
      if (path.extension(file.path).isEmpty) continue;
      String imageName = path.basename(file.path);
      if (imageName.contains("watermark")) {
        continue;
      }
      final outputFile = File(path.join(outputDirectory!, imageName));

      final imageBytes = await file.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      final exifData = await readExifFromBytes(imageBytes);
      String orientation = exifData['Image Orientation']?.printable ?? "Horizontal";
      if (image != null) {
        var editedImage = _applyWatermarkToFile(image, orientation);
        if (editedImage != null) {
          img.Image finalImage = _applyTextToFile(editedImage, imageName);
          await outputFile.writeAsBytes(img.encodeJpg(finalImage));
          if (callback != null) {
            callback!((++count/imagesInDir.length * 100));
          }
        }
      }
    }
  }

  Future<void> _setup() async {
    await _validateDirectories();
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

  Future<void> _validateDirectories() async {
    if (watermarkPath == null || inputFolderPath == null || outputDirectory == null) {
      throw DetailedException(
          "The provided directory/ies are invalid.",
          "Watermark: $watermarkPath\nInput Image Folder: $inputFolderPath \nOutput Folder: $outputDirectory");
    }
    if (await Directory(outputDirectory!).exists()){
      await Directory(outputDirectory!).delete(recursive: true);
    }
    await Directory(outputDirectory!).create(recursive: true);
  }

  img.Image? _applyWatermarkToFile(img.Image image, String orientation) {
    img.Image? resizedImage = _resizeImage(image, orientation);
    if (resizedImage != null) {
      var (posX, posY) = _determineWatermarkPosition(resizedImage.height, resizedImage.width);
      resizedImage = img.drawImage(resizedImage, watermark!, dstX: posX, dstY: posY);
    }
    return resizedImage;
  }

  img.Image _applyTextToFile(img.Image image, String text) {
    if (!textEnabled!) return image;
    var (font, offset) = _getFont();
    img.Image textImg = img.drawStringCentered(image, font, text.split(".")[0], y: image.height - offset, color: _getColour());
    return textImg;
  }

  img.Image? _resizeImage(img.Image orig, String orientation) {
    img.Image resizedImage = img.copyResize(orig,
        width: orig.width ~/ scale,
        height: orig.height ~/ scale,
        interpolation: img.Interpolation.cubic);

    if (orientation.contains("90 CCW")) {
      resizedImage = img.copyRotate(resizedImage, -90);
    }

    return img.decodeImage(img.encodeJpg(resizedImage, quality: quality));
  }

  (img.BitmapFont, int) _getFont() {
    switch (fontSize) {
      case FontSize.small:
        return (arial_14, 15);
      case FontSize.medium:
        return (arial_24, 25);
      case FontSize.large:
        return (arial_48, 50);
    }
  }

  int _getColour() {
    switch (colour) {
      case Colour.black:
        return Color.fromRgb(0, 0, 0);
      case Colour.white:
        return Color.fromRgb(255, 255, 255);
      case Colour.green:
        return Color.fromRgb(117, 249, 77);
      case Colour.red:
        return Color.fromRgb(235, 51, 36);
      case Colour.blue:
        return Color.fromRgb(99, 195, 253);
    }
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

