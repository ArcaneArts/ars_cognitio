import 'package:ars_cognitio/sugar.dart';
import 'package:dialoger/dialoger.dart';
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
                icon: const Icon(Icons.copy_rounded)),
            IconButton(
                onPressed: () => dialogConfirm(
                    context: context,
                    title: "Delete Image?",
                    description:
                        "An attempt will be made to delete it off of the Stable Diffusion API's history, if it succeeds, we will also delete it here, otherwise it wont be deleted here.\n\nNote: Thumbnails & API History is still stored on the StableDiffusion API Servers & Dashboard!",
                    confirmButtonText: "Server Delete",
                    onConfirm: (context) {
                      stableDiffusionService()
                          .serverDeleteImage(widget.image)
                          .then((value) {
                        if (value) {
                          snack("Successful Server Delete!");
                          saveData((d) => d.getGenerated().removeWhere(
                              (element) => element == widget.image));
                          Future.delayed(Duration(milliseconds: 50),
                              () => Navigator.pop(context));
                        } else {
                          snack("Failed Server Delete!");
                        }
                      });
                    }),
                icon: const Icon(Icons.delete_rounded))
          ],
        ),
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: InteractiveViewer(
              maxScale: 5,
              child: Image.network(widget.image),
            ),
          ),
        ),
      );
}
