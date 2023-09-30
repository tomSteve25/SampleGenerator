import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:sample_generator/WatermarkPositionEnum.dart';
import 'package:sample_generator/image_processor.dart';
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
  WatermarkPosition _watermarkPosition = WatermarkPosition.center;
  final _directoryController = TextEditingController();
  final _watermarkController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ImageEditor imageEditor = ImageEditor();

  @override
  void initState() {
    super.initState();
    _imageDirectory = widget.pref.getString("imageDirectory");
    _directoryController.text = _imageDirectory ?? "Select a image folder";
    imageEditor.inputFolderPath = _imageDirectory;
    _watermarkDirectory = widget.pref.getString("watermarkPath");
    _watermarkController.text = _watermarkDirectory ?? "Select a watermark";
    imageEditor.watermarkPath = _watermarkDirectory;
  }

  Future<void> processImages() async {
    print("Starting processing");
    final inputFolderPath = _imageDirectory;
    final outputFolderPath = path.join(inputFolderPath!, 'output');
    Directory(outputFolderPath).createSync(recursive: true);
    imageEditor.outputDirectory = outputFolderPath;
    imageEditor.watermarkPath = _watermarkDirectory;
    imageEditor.watermarkPosition = _watermarkPosition;

    imageEditor.applyWatermarkToDirectory();
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
        imageEditor.inputFolderPath = path;

      });
      widget.pref.setString("imageDirectory", path);
    }
  }

  Future<void> selectWatermark() async {
    FilePickerResult? files = await FilePicker.platform.pickFiles(
        type: FileType.image,
        dialogTitle: "Please pick a watermark image",
        initialDirectory: path.dirname(_watermarkDirectory!)
    );
    if (files != null) {
      setState(() {
        _watermarkDirectory = files.paths.first;
        _watermarkController.text = files.paths.first ?? _watermarkController.text;
        imageEditor.watermarkPath = _watermarkController.text;
      });
      widget.pref.setString("watermarkPath", _watermarkDirectory!);
    }
  }

  bool checkIfButtonsShouldBeDisabled() {
    return !(_imageDirectory != null && _watermarkDirectory != null);
  }

  void radioButtonCallback(WatermarkPosition? value) {
    setState(() {
      _watermarkPosition = value ?? _watermarkPosition;
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
