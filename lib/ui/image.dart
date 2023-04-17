import 'package:ars_cognitio/model/generated_image.dart';
import 'package:ars_cognitio/sugar.dart';
import 'package:dialoger/dialoger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snackbar/snackbar.dart';

class ImageScreen extends StatefulWidget {
  final GeneratedImage image;
  const ImageScreen({Key? key, required this.image}) : super(key: key);

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  bool _zooming = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("Image Viewer"),
          actions: [
            _zooming
                ? const CircularProgressIndicator()
                : widget.image.superImage != null
                    ? Container()
                    : IconButton(
                        onPressed: () {
                          setState(() {
                            _zooming = true;
                          });
                          stableDiffusionService()
                              .superResolution(widget.image.image!, 4,
                                  enhanceFace: true)
                              .then((value) {
                            saveData((d) {
                              d
                                  .getGenerated()
                                  .singleWhere((element) =>
                                      element.image == widget.image.image)
                                  .superImage = value;
                            });
                            setState(() {});
                          });
                        },
                        tooltip: "Super Resolution",
                        icon:
                            const Icon(Icons.photo_size_select_large_rounded)),
            IconButton(
                onPressed: () {
                  saveData((d) {
                    d.getSettings().promptStrength =
                        widget.image.promptStrength;
                    d.getSettings().guidanceScale = widget.image.guidanceScale;
                    d.getSettings().safetyChecker = widget.image.safetyChecker;
                    d.getSettings().enhancePrompt = widget.image.enhancePrompt;
                    d.getSettings().width = widget.image.width;
                    d.getSettings().height = widget.image.height;
                    d.getSettings().inferenceSteps =
                        widget.image.inferenceSteps;
                  });
                  Future.delayed(
                      const Duration(milliseconds: 250),
                      () => Navigator.pop(
                          context,
                          GeneratedImage()
                            ..image = widget.image.image
                            ..prompt = widget.image.prompt
                            ..model = widget.image.model
                            ..negativePrompt = widget.image.negativePrompt
                            ..promptImage = widget.image.image));
                },
                icon: const Icon(Icons.edit_rounded)),
            IconButton(
                onPressed: () {
                  saveData((d) {
                    d.getSettings().promptStrength =
                        widget.image.promptStrength;
                    d.getSettings().guidanceScale = widget.image.guidanceScale;
                    d.getSettings().safetyChecker = widget.image.safetyChecker;
                    d.getSettings().enhancePrompt = widget.image.enhancePrompt;
                    d.getSettings().width = widget.image.width;
                    d.getSettings().height = widget.image.height;
                    d.getSettings().inferenceSteps =
                        widget.image.inferenceSteps;
                  });
                  Future.delayed(const Duration(milliseconds: 250),
                      () => Navigator.pop(context, widget.image));
                },
                icon: const Icon(Icons.settings_suggest_rounded)),
            IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.image.image))
                      .then((value) => snack("Copied URL to clipboard"));
                },
                icon: const Icon(Icons.copy_rounded)),
            IconButton(
                onPressed: () => stableDiffusionService()
                    .deleteDialog(context, widget.image.image!),
                icon: const Icon(Icons.delete_rounded))
          ],
        ),
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: InteractiveViewer(
              maxScale: 5,
              child: Image.network(widget.image.bestImage()),
            ),
          ),
        ),
      );
}
