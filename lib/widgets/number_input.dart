import 'package:fluent_ui/fluent_ui.dart';
import 'package:sample_generator/page.dart';

class NumberInput extends StatefulWidget {
  const NumberInput({
    super.key,
    required this.title,
    required this.message,
    required this.enteredValue,
    required this.callback,
  });

  final void Function(double?)? callback;
  final String? title;
  final String? message;
  final double? enteredValue;

  @override
  State<NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<NumberInput> with AutomaticKeepAliveClientMixin<NumberInput>, PageMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        subtitle(content: Text(widget.title ?? "Title")),
        description(content: Text(widget.message ?? "Message")),
        SizedBox(
          width: 100,
          child: NumberBox(
            value: widget.enteredValue,
            onChanged: widget.callback,
            smallChange: 0.1,
            min: 0,
            max: 15,
            mode: SpinButtonPlacementMode.none,
          ),
        ),

      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}