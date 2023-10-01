import 'package:fluent_ui/fluent_ui.dart';

import '../page.dart';

class CustomErrorWidget extends StatefulWidget {
  const CustomErrorWidget({super.key,
    required this.errorTitle,
    this.errorDetails,
  });

  final String? errorTitle;
  final String? errorDetails;

  @override
  State<CustomErrorWidget> createState() => _CustomErrorWidgetState();
}

class _CustomErrorWidgetState extends State<CustomErrorWidget> with PageMixin {
  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text("Error", style: TextStyle(fontWeight: FontWeight.bold),),
      // constraints: const BoxConstraints(maxHeight: 200, maxWidth: 100),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          subtitle(content: Text(widget.errorTitle ?? "There has been an error")),
          Text(widget.errorDetails ?? "No details to display")
        ],
      ),
      actions: [
        Button(
          child: const Text('Ok'),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}