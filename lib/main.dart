import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:sample_generator/page.dart';
import 'package:sample_generator/service/enums/colours.dart';
import 'package:sample_generator/service/enums/font_size.dart';
import 'package:sample_generator/service/exceptions/detailed_exception.dart';
import 'package:sample_generator/service/image_processor.dart';
import 'package:sample_generator/widgets/ErrorWidget.dart';
import 'package:sample_generator/widgets/card_highlight.dart';
import 'package:sample_generator/widgets/number_input.dart';
import 'package:sample_generator/widgets/position_select.dart';
import 'package:sample_generator/widgets/text_adder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'service/enums/watermark_position.dart';
import 'theme.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  pref = await loadPreferences();
  runApp(MyApp(pref: pref,));
}

final _appTheme = AppTheme();
late final SharedPreferences pref;

Future<SharedPreferences> loadPreferences() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  if (pref.getDouble("scale") == null) {
    pref.setDouble("scale", 10);
  }
  if (pref.getDouble("watermarkScale") == null) {
    pref.setDouble("watermarkScale", 1);
  }
  if (pref.getBool("textEnabled") == null) {
    pref.setBool("textEnabled", true);
  }
  if (pref.getString("textColour") == null) {
    pref.setString("textColour", "Black");
  }
  if (pref.getString("fontSize") == null) {
    pref.setString("fontSize", "Medium");
  }

  return pref;
}

class MyApp extends StatelessWidget {
  final SharedPreferences pref;

  const MyApp({super.key, required this.pref});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _appTheme,
      builder: (context, child) {
        final appTheme = context.watch<AppTheme>();
        return FluentApp(
          title: "Sample Generator",
          themeMode: appTheme.mode,
          debugShowCheckedModeBanner: false,
          color: appTheme.color,
          darkTheme: FluentThemeData(
            brightness: Brightness.dark,
            accentColor: appTheme.color,
            visualDensity: VisualDensity.standard,
            focusTheme: FocusThemeData(
              glowFactor: is10footScreen(context) ? 2.0 : 0.0,
            ),
          ),
          theme: FluentThemeData(
            accentColor: appTheme.color,
            visualDensity: VisualDensity.standard,
            focusTheme: FocusThemeData(
              glowFactor: is10footScreen(context) ? 2.0 : 0.0,
            ),
          ),
          locale: appTheme.locale,
          home: HomePage(pref: pref)
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  final SharedPreferences pref;

  const HomePage({
    super.key,
    required this.pref
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with PageMixin {
  String? _imageDirectory;
  String? _outputDirectory;
  String? _watermarkDirectory;
  double? _scale;
  double? _watermarkScale;
  double _percentageCompleted = 0;
  WatermarkPosition _watermarkPosition = WatermarkPosition.center;
  ImageEditor imageEditor = ImageEditor();
  bool _disabled = false;
  bool? _textEnabled;
  Colour _textColour = Colour.black;
  FontSize _selectedFontSize = FontSize.medium;

  @override
  void initState() {
    super.initState();
    _imageDirectory = widget.pref.getString("imageDirectory");
    _outputDirectory = _imageDirectory != null ? path.join(_imageDirectory!, 'output') : null;
    _watermarkDirectory = widget.pref.getString("watermarkPath");
    _scale = widget.pref.getDouble("scale");
    _watermarkScale = widget.pref.getDouble("watermarkScale");
    _textEnabled = widget.pref.getBool("textEnabled");
    _textColour = Colour.fromString(widget.pref.getString("textColour") ?? "black");
    _selectedFontSize = FontSize.fromString(widget.pref.getString("fontSize") ?? "medium");
    imageEditor.callback = setPercentageCompleted;
  }

  Future<void> selectImageDirectory() async {
    String? filePath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: "Select a folder of images",
        initialDirectory: _imageDirectory);
    if (filePath != null) {
      setState(() {
        _imageDirectory = filePath;
        _outputDirectory = path.join(_imageDirectory!, 'output');
        imageEditor.inputFolderPath = filePath;
      });
      widget.pref.setString("imageDirectory", filePath);
      print("");
    }
  }

  Future<void> selectOutputDirectory() async {
    String? filePath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: "Select a folder for the output",
        initialDirectory: _outputDirectory);
    if (filePath != null) {
      setState(() {
        _outputDirectory = filePath;
        imageEditor.outputDirectory = filePath;
      });
    }
  }

  Future<void> selectWatermark() async {
    FilePickerResult? files = await FilePicker.platform.pickFiles(
      type: FileType.image,
      dialogTitle: "Please pick a watermark image",
      initialDirectory: _watermarkDirectory != null ? path.dirname(_watermarkDirectory!) : null
    );
    if (files != null) {
      setState(() {
        _watermarkDirectory = files.paths.first;
        imageEditor.watermarkPath = files.paths.first;
      });
      widget.pref.setString("watermarkPath", _watermarkDirectory!);
    }
  }

  void selectWatermarkPositionCallback(WatermarkPosition? position) {
    setState(() {
      _watermarkPosition = position ?? _watermarkPosition;
    });
  }

  void selectImageScaleCallback(double? scale) {
    setState(() {
      _scale = scale ?? _scale;
      widget.pref.setDouble("scale", _scale!);
    });
  }

  void selectWatermarkScaleCallback(double? scale) {
    setState(() {
      _watermarkScale = scale ?? _watermarkScale;
      widget.pref.setDouble("watermarkScale", _watermarkScale!);
    });
  }

  void addTextCallback(bool? enabled, Colour? colour, FontSize? fontSize) {
    setState(() {
      _textEnabled = enabled ?? _textEnabled;
      widget.pref.setBool("textEnabled", _textEnabled!);
      _textColour = colour ?? _textColour;
      widget.pref.setString("textColour", _textColour.name);
      _selectedFontSize = fontSize ?? _selectedFontSize;
      widget.pref.setString("fontSize", _selectedFontSize.name);
    });
  }

  Future<void> processImages() async {
    setState(() {
      _disabled = true;
    });
    try {
      imageEditor.inputFolderPath = _imageDirectory;
      imageEditor.outputDirectory = _outputDirectory;
      imageEditor.watermarkPath = _watermarkDirectory;
      imageEditor.watermarkPosition = _watermarkPosition;
      imageEditor.scale = _scale ?? 10;
      imageEditor.watermarkScale = _watermarkScale ?? 1;
      imageEditor.textEnabled = _textEnabled;
      imageEditor.colour = _textColour;
      imageEditor.fontSize = _selectedFontSize;
      await imageEditor.applyWatermarkToDirectory();
    } on DetailedException catch(e) {
      showContentDialog(context, e);
    } on Exception catch (ex) {
      var tempException = DetailedException("Runtime Exception", ex.toString());
      showContentDialog(context, tempException);
    } finally {
      setState(() {
        _disabled = false;
        _percentageCompleted = 0;
      });
    }
  }

  void showContentDialog(BuildContext context, DetailedException ex) async {
    await showDialog<String>(
      context: context,
      builder: (context) => CustomErrorWidget(errorTitle: ex.title, errorDetails: ex.message,)
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
        content: ScaffoldPage.scrollable(
          header: const PageHeader(title: Text("Settings"),),
          children: [
            const Text("This application allows for automatic generation of downsampled images with an applied watermark"),
            subtitle(content: const Text("Image Directory")),
            description(content: const Text("This directory contains the images that you want to apply the transformations to")),
            CardHighlight(message: _imageDirectory ?? "Please select a directory", callback: _disabled ? null : selectImageDirectory, icon: FluentIcons.folder_horizontal,),
            subtitle(content: const Text("Watermark")),
            description(content: const Text("This is the image you want to use as a watermark. It's recommended to use a transparent format (e.g. PNG)")),
            CardHighlight(message: _watermarkDirectory ?? "Please select a watermark", callback: _disabled ? null : selectWatermark, icon: FluentIcons.file_image,),
            subtitle(content: const Text("Output Directory")),
            description(content: const Text("This is the output directory. This defaults to a subdirectory of the input directory called 'output'")),
            CardHighlight(message: _outputDirectory ?? 'This will be set automatically, or set it yourself', callback: _disabled ? null : selectOutputDirectory, icon: FluentIcons.file_image,),
            Wrap(
              spacing: 50,
              children: <Widget>[
                PositionSelect(callback: selectWatermarkPositionCallback, enabled: !_disabled,),
                NumberInput(enteredValue: _scale, callback: _disabled ? null : selectImageScaleCallback, title: "Image scale", message: "The reduction ratio of the original image",),
                NumberInput(enteredValue: _watermarkScale, callback: _disabled ? null : selectWatermarkScaleCallback, title: "Watermark scale", message: "The reduction ratio of the watermark",),
              ],
            ),
            TextAdder(callback: addTextCallback, enabled: !_disabled, colour: _textColour, fontSize: _selectedFontSize, textEnabled: _textEnabled ?? false,),
            const SizedBox(height: 20,),
            Container(
              child: _disabled ?  ProgressBar(value: _percentageCompleted) : FilledButton(onPressed: processImages, child: const Text("Generate Samples"),),
            ),
          ],
        )
    );
  }

  void setPercentageCompleted(double? num) {
    setState(() {
      _percentageCompleted = num ?? 0;
    });
  }
}