import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences pref = await loadPreferences();
  runApp(MyApp(
    pref: pref,
  ));
}

Future<SharedPreferences> loadPreferences() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  if (pref.getDouble("scale") == null) {
    pref.setDouble("scale", 10);
  }
  if (pref.getString("watermarkPath") == null) {
    pref.setString("watermarkPath", "assets/watermark.png");
  }
  return pref;
}

enum WatermarkPosition { center, topLeft, topRight, bottomLeft, bottomRight }

class MyApp extends StatelessWidget {
  final SharedPreferences pref;

  const MyApp({super.key, required this.pref});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(
        pref: pref,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final SharedPreferences pref;

  const MyHomePage({super.key, required this.pref});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> selectedFiles = [];
  String? _imageDirectory;
  String? _watermarkDirectory;
  bool _processImagesDisabled = true;
  WatermarkPosition? _watermarkPosition = WatermarkPosition.center;
  final _directoryController = TextEditingController();
  final _watermarkController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _imageDirectory = widget.pref.getString("imageDirectory");
    _directoryController.text = _imageDirectory ?? "Select a image folder";
    _watermarkDirectory = widget.pref.getString("watermarkPath");
    _watermarkController.text = _watermarkDirectory ?? "Select a watermark";
  }

  Future<void> processImages() async {
    print("Starting processing");
    final inputFolderPath = _imageDirectory;

    final folderPath = await getApplicationDocumentsDirectory();
    final outputFolderPath = path.join(folderPath.path, 'output');

    Directory(outputFolderPath).createSync(recursive: true);
    final watermark =
        img.decodeImage(File(_watermarkDirectory!).readAsBytesSync());
    if (watermark == null) {
      debugPrint('Failed to load the watermark image.');
      return;
    }

    // Process each image in the selected folder
    for (var file in Directory(inputFolderPath!).listSync()) {
      final imageName = path.basename(file.path);
      debugPrint("Image name: ${file.path}");
      if (file.path.contains("watermark")) {
        continue;
      }
      final inputFile = File(file.path);
      final outputFile = File(path.join(outputFolderPath, imageName));

      // Copy original image
      await inputFile.copy(outputFile.path);

      // Process the image (resize and add watermark)
      final image = img.decodeImage(await inputFile.readAsBytes());
      if (image != null) {
        img.Image? resizedImage = img.copyResize(image,
            width: image.width ~/ 10,
            height: image.height ~/ 10,
            interpolation: img.Interpolation.cubic);
        resizedImage =
            img.decodeImage(img.encodeJpg(resizedImage, quality: 10));
        if (resizedImage == null) {
          return;
        }
        int posX = resizedImage.width ~/ 2 - watermark.width ~/ 2;
        int posY = resizedImage.height ~/ 2 - watermark.height ~/ 2;
        switch (_watermarkPosition) {
          case WatermarkPosition.topLeft:
            posX = 0;
            posY = 0;
            break;
          case WatermarkPosition.topRight:
            posX = resizedImage.width - watermark.width;
            posY = 0;
            break;
          case WatermarkPosition.bottomLeft:
            posX = 0;
            posY = resizedImage.height - watermark.height;
            break;
          case WatermarkPosition.bottomRight:
            posX = resizedImage.width - watermark.width;
            posY = resizedImage.height - watermark.height;
            break;
          case WatermarkPosition.center:
          case null:
            break;
        }
        img.drawImage(resizedImage, watermark, dstX: posX, dstY: posY);
        outputFile.writeAsBytesSync(img.encodeJpg(resizedImage));
        // OpenFile.open(outputFile.path);
      }
    }
    print("Finished");
  }

  Future<void> selectImageDirectory() async {
    String? path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: "Select a folder of images",
      initialDirectory: _imageDirectory
    );
    if (path != null) {
      setState(() {
        _imageDirectory = path;
        _directoryController.text = path;
      });
      widget.pref.setString("imageDirectory", path);
    }
  }

  Future<void> selectWatermark() async {
    FilePickerResult? files = await FilePicker.platform.pickFiles(
        type: FileType.image,
        dialogTitle: "Please pick a watermark image",
        initialDirectory: _watermarkDirectory
    );
    if (files != null) {
      setState(() {
        _watermarkDirectory = files.paths.first;
        _watermarkController.text = files.paths.first!;
      });
      widget.pref.setString("watermarkPath", _watermarkDirectory!);
    }
  }

  bool checkIfButtonsShouldBeDisabled() {
    return !(_imageDirectory != null && _watermarkDirectory != null);
  }

  void radioButtonCallback(WatermarkPosition? value) {
    setState(() {
      _watermarkPosition = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Processor'),
      ),
      body: Center(
        child: Padding(
            padding: const EdgeInsets.all(15),
            child: Form(
                key: _formKey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                TextFormField(
                                  controller: _directoryController,
                                  readOnly: true,
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic),
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        value == "Select a directory") {
                                      return 'Select a directory';
                                    }
                                    return null;
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: ElevatedButton(
                                    onPressed: selectImageDirectory,
                                    child: const Text("Select a directory"),
                                  ),
                                ),
                              ],
                            )),
                        Container(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                TextFormField(
                                  controller: _watermarkController,
                                  readOnly: true,
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic),
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        value == "Select a watermark") {
                                      return 'Select a watermark';
                                    }
                                    return null;
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: ElevatedButton(
                                    onPressed: selectWatermark,
                                    child: const Text("Select a watermark"),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        processImages();
                                      }
                                    },
                                    child: const Text('Apply watermarks'),
                                  ),
                                ),
                              ],
                            )),
                      ],
                    )),
                    Expanded(
                        child: Column(
                      children: <Widget>[
                        RadioListTile(
                          title: const Text("Center"),
                          value: WatermarkPosition.center,
                          groupValue: _watermarkPosition,
                          onChanged: radioButtonCallback,
                        ),
                        RadioListTile(
                          title: const Text('Top Left'),
                          value: WatermarkPosition.topLeft,
                          groupValue: _watermarkPosition,
                          onChanged: radioButtonCallback,
                        ),
                        RadioListTile(
                          title: const Text('Top Right'),
                          value: WatermarkPosition.topRight,
                          groupValue: _watermarkPosition,
                          onChanged: radioButtonCallback,
                        ),
                        RadioListTile(
                          title: const Text('Bottom Left'),
                          value: WatermarkPosition.bottomLeft,
                          groupValue: _watermarkPosition,
                          onChanged: radioButtonCallback,
                        ),
                        RadioListTile(
                          title: const Text('Bottom Right'),
                          value: WatermarkPosition.bottomRight,
                          groupValue: _watermarkPosition,
                          onChanged: radioButtonCallback,
                        ),
                      ],
                    ))
                  ],
                ))),
      ),
    );
  }
}
