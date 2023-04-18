import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownText extends StatelessWidget {
  final String content;

  const MarkdownText({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) => MarkdownBody(
        data: content,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          pPadding: const EdgeInsets.only(top: 5, bottom: 5),
          tableBorder: TableBorder.all(
              borderRadius: BorderRadius.circular(7),
              width: 1,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .color!
                  .withOpacity(0.5)),
        ),
      );
}
