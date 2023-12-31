import 'package:fluent_ui/fluent_ui.dart';
import 'package:sample_generator/page.dart';
import 'package:sample_generator/service/enums/watermark_position.dart';

class PositionSelect extends StatefulWidget {
  const PositionSelect({
    super.key,
    required this.callback,
    required this.enabled
  });

  final void Function(WatermarkPosition?)? callback;
  final bool enabled;

  @override
  State<PositionSelect> createState() => _PositionSelectState();
}

class _PositionSelectState extends State<PositionSelect> with AutomaticKeepAliveClientMixin<PositionSelect>, PageMixin {
  WatermarkPosition _selectedPosition = WatermarkPosition.center;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        subtitle(content: const Text("Watermark Position")),
        description(content: const Text("The position of the watermark relative to the original image")),
        ComboBox<WatermarkPosition>(
          value: _selectedPosition,
          onChanged: !widget.enabled ? null : callback,
          items: WatermarkPosition.values.map((e) {
            return ComboBoxItem(
              value: e,
              child: Text(e.name),
            );
          }).toList(),
        )
      ],
    );
  }

  void callback(WatermarkPosition? pos) {
    setState(() {
      _selectedPosition = pos ?? _selectedPosition;
    });
    if(widget.callback != null) {
      widget.callback!(pos);
    }
  }

  @override
  bool get wantKeepAlive => true;
}