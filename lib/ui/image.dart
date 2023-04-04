import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snackbar/snackbar.dart';

class ImageScreen extends StatefulWidget {
  final String image;
  const ImageScreen({Key? key, required this.image}) : super(key: key);

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("Image Viewer"),
          actions: [
            IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.image))
                      .then((value) => snack("Copied URL to clipboard"));
                },
                icon: const Icon(Icons.copy_rounded))
          ],
        ),
        body: Center(
          child: InteractiveViewer(
            child: Image.network(widget.image),
          ),
        ),
      );
}
