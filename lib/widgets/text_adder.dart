import 'package:fluent_ui/fluent_ui.dart';
import 'package:sample_generator/page.dart';
import 'package:sample_generator/service/enums/colours.dart';
import 'package:sample_generator/service/enums/font_size.dart';
import 'package:sample_generator/widgets/colour_picker.dart';
import 'package:sample_generator/widgets/fontsize_picker.dart';

class TextAdder extends StatefulWidget {
  const TextAdder({super.key, required this.callback, required this.enabled, required this.colour, required this.fontSize, required this.textEnabled});

  final void Function(bool?, Colour?, FontSize?)? callback;
  final bool enabled;
  final bool textEnabled;
  final Colour colour;
  final FontSize fontSize;

  @override
  State<TextAdder> createState() => _TextAdderSelectState();
}

class _TextAdderSelectState extends State<TextAdder>
    with AutomaticKeepAliveClientMixin<TextAdder>, PageMixin {
  late bool _textEnabled;
  late Colour _selectedColour;
  late FontSize _selectedFontSize;

  @override
  void initState() {
    super.initState();
    _selectedColour = widget.colour;
    _selectedFontSize = widget.fontSize;
    _textEnabled = widget.textEnabled;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        subtitle(content: const Text("Image Text")),
        description(
            content: const Text("Add filename to the bottom of the image")),
        Row(
          // mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Flexible(
              // flex: 1,
              // fit: FlexFit.tight,
              child: ColourPicker(
              callback: colourCallback,
              enabled: _textEnabled && widget.enabled,
                colour: _selectedColour,
            )),
            Container(width: 50,),
            Flexible(
              // flex: 1,
              fit: FlexFit.tight,
              child: FontSizePicker(
                  callback: fontSizeCallback,
                  enabled: _textEnabled && widget.enabled,
                  fontSize: _selectedFontSize,
              ),
            ),
            Flexible(
              flex: 3,
              fit: FlexFit.tight,
              child: ToggleSwitch(
              checked: _textEnabled,
              onChanged: !widget.enabled
                  ? null
                  : (v) {
                      setState(() {
                        _textEnabled = v;
                      });
                      callback();
                    },
              content: const Text('Enabled'),
            ))
          ],
        ),
      ],
    );
  }

  void colourCallback(Colour? colour) {
    setState(() {
      _selectedColour = colour ?? _selectedColour;
    });
    callback();
  }

  void fontSizeCallback(FontSize? size) {
    setState(() {
      _selectedFontSize = size ?? _selectedFontSize;
    });
    callback();
  }

  void callback() {
    if (widget.callback != null) {
      widget.callback!(_textEnabled, _selectedColour, _selectedFontSize);
    }
  }

  @override
  bool get wantKeepAlive => true;
}
