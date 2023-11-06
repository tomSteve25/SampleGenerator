import 'package:fluent_ui/fluent_ui.dart';
import 'package:sample_generator/page.dart';
import 'package:sample_generator/service/enums/colours.dart';

class ColourPicker extends StatefulWidget {
  const ColourPicker({
    super.key,
    required this.callback,
    required this.enabled,
    required this.colour
  });

  final void Function(Colour?)? callback;
  final bool enabled;
  final Colour colour;

  @override
  State<ColourPicker> createState() => _ColourPickerSelectState();
}

class _ColourPickerSelectState extends State<ColourPicker> with AutomaticKeepAliveClientMixin<ColourPicker>, PageMixin {
  late Colour _selectedColour;

  @override
  void initState() {
    super.initState();
    _selectedColour = widget.colour;
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        subtitle(content: const Text("Colour", style: TextStyle(fontSize: 15),)),
        Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ComboBox<Colour>(
                value: _selectedColour,
                onChanged: !widget.enabled ? null : (c) {
                  setState(() {
                    _selectedColour = c ?? _selectedColour;
                  });
                  callback();
                },
                items: Colour.values.map((e) {
                  return ComboBoxItem(
                    value: e,
                    child: Text(e.name),
                  );
                }).toList(),
              ),
            ]
        ),
      ],
    );
  }

  void callback() {
    if(widget.callback != null) {
      widget.callback!(_selectedColour);
    }
  }

  @override
  bool get wantKeepAlive => true;
}