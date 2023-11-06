import 'package:fluent_ui/fluent_ui.dart';
import 'package:sample_generator/page.dart';
import 'package:sample_generator/service/enums/font_size.dart';

class FontSizePicker extends StatefulWidget {
  const FontSizePicker({
    super.key,
    required this.callback,
    required this.enabled,
    required this.fontSize
  });

  final void Function(FontSize?)? callback;
  final bool enabled;
  final FontSize fontSize;


  @override
  State<FontSizePicker> createState() => _FontSizePickerSelectState();
}

class _FontSizePickerSelectState extends State<FontSizePicker> with AutomaticKeepAliveClientMixin<FontSizePicker>, PageMixin {
  late FontSize _selectedSize;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.fontSize;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        subtitle(content: const Text("Font Size", style: TextStyle(fontSize: 15),)),
        Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ComboBox<FontSize>(
                value: _selectedSize,
                onChanged: !widget.enabled ? null : (c) {
                  setState(() {
                    _selectedSize = c ?? _selectedSize;
                  });
                  callback();
                },
                items: FontSize.values.map((e) {
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
      widget.callback!(_selectedSize);
    }
  }

  @override
  bool get wantKeepAlive => true;
}