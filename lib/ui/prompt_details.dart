import 'package:ars_cognitio/model/generated_image.dart';
import 'package:flutter/material.dart';
import 'package:padded/padded.dart';

class PromptDetails extends StatelessWidget {
  final GeneratedImage image;
  const PromptDetails({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        child: PaddingAll(
          padding: 7,
          child: Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (image.superImage != null)
                PaddingRight(
                    padding: 14,
                    child: Icon(
                      Icons.upcoming_rounded,
                      color: Colors.deepPurpleAccent,
                      size: 64,
                    )),
              if (image.promptImage != null)
                PaddingRight(
                  padding: 14,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      image.promptImage!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              PaddingRight(
                  padding: 14,
                  child: Text(
                    image.prompt ?? "",
                    style: const TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  )),
              if ((image.negativePrompt ?? "").isNotEmpty)
                Text(
                  image.negativePrompt ?? "",
                  style: const TextStyle(fontSize: 24, color: Colors.red),
                  textAlign: TextAlign.center,
                )
            ],
          ),
        ),
      );
}
