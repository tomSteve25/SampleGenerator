import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

class CardHighlight extends StatefulWidget {
  CardHighlight({
    super.key,
    this.backgroundColor,
    this.header,
    required this.icon,
    required this.message,
    required this.callback,
  });

  final Widget? header;
  final String message;
  final IconData? icon;
  final VoidCallback? callback;
  final Color? backgroundColor;

  @override
  State<CardHighlight> createState() => _CardHighlightState();
}

class _CardHighlightState extends State<CardHighlight> with AutomaticKeepAliveClientMixin<CardHighlight> {

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = FluentTheme.of(context);

    return
      Mica(
        backgroundColor: widget.backgroundColor ?? theme.resources.controlAltFillColorQuarternary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4.0)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Align(
            alignment: AlignmentDirectional.topStart,
            child: TextBox(
              readOnly: true,
              placeholder: widget.message,
              maxLength: 50,
              suffix: IconButton(
                icon: Icon(widget.icon),
                onPressed: widget.callback,
              ),
            )
          ),
        ),
      );
  }

  @override
  bool get wantKeepAlive => true;
}

const fluentHighlightTheme = {
  'root': TextStyle(
    backgroundColor: Color(0x00ffffff),
    color: Color(0xffdddddd),
  ),
  'keyword': TextStyle(
      color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold),
  'selector-tag':
      TextStyle(color: Color(0xffffffff), fontWeight: FontWeight.bold),
  'literal': TextStyle(color: Color(0xffffffff), fontWeight: FontWeight.bold),
  'section': TextStyle(color: Color(0xffffffff), fontWeight: FontWeight.bold),
  'link': TextStyle(color: Color(0xffffffff)),
  'subst': TextStyle(color: Color(0xffdddddd)),
  'string': TextStyle(color: Color(0xffdd8888)),
  'title': TextStyle(color: Color(0xffdd8888), fontWeight: FontWeight.bold),
  'name': TextStyle(color: Color(0xffdd8888), fontWeight: FontWeight.bold),
  'type': TextStyle(color: Color(0xffdd8888), fontWeight: FontWeight.bold),
  'attribute': TextStyle(color: Color(0xffdd8888)),
  'symbol': TextStyle(color: Color(0xffdd8888)),
  'bullet': TextStyle(color: Color(0xffdd8888)),
  'built_in': TextStyle(color: Color(0xffdd8888)),
  'addition': TextStyle(color: Color(0xffdd8888)),
  'variable': TextStyle(color: Color(0xffdd8888)),
  'template-tag': TextStyle(color: Color(0xffdd8888)),
  'template-variable': TextStyle(color: Color(0xffdd8888)),
  'comment': TextStyle(color: Color(0xff777777)),
  'quote': TextStyle(color: Color(0xff777777)),
  'deletion': TextStyle(color: Color(0xff777777)),
  'meta': TextStyle(color: Color(0xff777777)),
  'doctag': TextStyle(fontWeight: FontWeight.bold),
  'strong': TextStyle(fontWeight: FontWeight.bold),
  'emphasis': TextStyle(fontStyle: FontStyle.italic),
};
