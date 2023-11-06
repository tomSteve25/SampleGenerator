import 'package:fluent_ui/fluent_ui.dart';

mixin PageMixin {
  Widget description({required Widget content}) {
    return Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 1.0),
        child: DefaultTextStyle(
          style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
          child: content,
        ),
      );
    });
  }

  Widget subtitle({required Widget content}) {
    return Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(top: 7.0, bottom: 2.0),
        child: DefaultTextStyle(
          style: const TextStyle(fontSize: 21),
          child: content,
        ),
      );
    });
  }
}