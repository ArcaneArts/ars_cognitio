import 'dart:async';

import 'package:ars_cognitio/model/diffusion_model.dart';
import 'package:ars_cognitio/model/generated_image.dart';
import 'package:ars_cognitio/services/diffusion_service.dart';
import 'package:ars_cognitio/sugar.dart';
import 'package:ars_cognitio/ui/diffusion_settings.dart';
import 'package:ars_cognitio/ui/image.dart';
import 'package:ars_cognitio/ui/prompt_details.dart';
import 'package:blur/blur.dart';
import 'package:dialoger/dialoger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:padded/padded.dart';
import 'package:snackbar/snackbar.dart';

class DiffusionScreen extends StatefulWidget {
  const DiffusionScreen({Key? key}) : super(key: key);

  @override
  State<DiffusionScreen> createState() => _DiffusionScreenState();
}

class _DiffusionScreenState extends State<DiffusionScreen> {
  bool loading = false;
  TextEditingController controller = TextEditingController();
  TextEditingController prompt = TextEditingController();
  TextEditingController negativePrompt = TextEditingController();
  DiffusionModel model = stableDiffusionService().defaultModel;
  String? initImageUrl;
  late final Timer _timer;

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      setState(() {
        stableDiffusionService().systemLoad();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [
            PaddingRight(
              padding: 14,
              child: StreamBuilder<SystemLoad>(
                stream: stableDiffusionService().streamSystemLoad(),
                builder: (context, snap) => snap.hasData
                    ? Text(
                        "${snap.data!.queued} Queued, ${snap.data!.queueTime}s ETA")
                    : const SizedBox(
                        height: 0,
                      ),
              ),
            ),
            FutureBuilder<List<DiffusionModel>>(
              future: stableDiffusionService().listModels(),
              builder: (context, snap) => snap.hasData
                  ? DropdownMenu<DiffusionModel>(
                      initialSelection: snap.data!.first,
                      controller: controller,
                      menuStyle: MenuStyle(
                        visualDensity: VisualDensity.compact,
                      ),
                      onSelected: (e) => model = e ?? model,
                      width: 200,
                      menuHeight: 500,
                      dropdownMenuEntries: [
                        ...snap.data!.map((e) => DropdownMenuEntry(
                            trailingIcon: IconButton(
                              color: thoseModels.contains(e.id)
                                  ? Colors.red
                                  : null,
                              icon: Icon(thoseModels.contains(e.id)
                                  ? Icons.warning_rounded
                                  : Icons.info_rounded),
                              onPressed: () {},
                              tooltip: e.description ?? "No description",
                            ),
                            value: e,
                            label: e.name ?? "Unnamed Model?"))
                      ],
                    )
                  : SizedBox(
                      height: 0,
                    ),
            )
          ],
          title: const Text("Diffusion"),
        ),
        body: Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                setState(() {
                  loading = true;
                });

                if (initImageUrl != null) {
                  await stableDiffusionService()
                      .image2Image(
                          model: model,
                          init: initImageUrl!,
                          prompt: prompt.text,
                          enhancePrompt:
                              data().getSettings().enhancePrompt ?? true,
                          width: data().getSettings().width ?? 512,
                          height: data().getSettings().height ?? 512,
                          inferenceSteps:
                              data().getSettings().inferenceSteps ?? 50,
                          guidanceScale:
                              data().getSettings().guidanceScale ?? 7.5,
                          promptStrength:
                              data().getSettings().promptStrength ?? 0.85,
                          safetyChecker:
                              data().getSettings().safetyChecker ?? true,
                          negativePrompt: negativePrompt.text)
                      .then((value) {
                    saveData((d) {
                      d.getGenerated().insert(0, value);
                    });

                    setState(() {
                      if ((value.image ?? "").isEmpty) {
                        snack(
                            "Failed to receive any images from the server. Please try again later.");
                      }
                      setState(() {
                        loading = false;
                      });
                    });
                  });
                } else {
                  await stableDiffusionService()
                      .text2Image(
                          model: model,
                          prompt: prompt.text,
                          enhancePrompt:
                              data().getSettings().enhancePrompt ?? true,
                          width: data().getSettings().width ?? 512,
                          height: data().getSettings().height ?? 512,
                          inferenceSteps:
                              data().getSettings().inferenceSteps ?? 50,
                          guidanceScale:
                              data().getSettings().guidanceScale ?? 7.5,
                          promptStrength:
                              data().getSettings().promptStrength ?? 0.85,
                          safetyChecker:
                              data().getSettings().safetyChecker ?? true,
                          negativePrompt: negativePrompt.text)
                      .then((value) {
                    saveData((d) {
                      d.getGenerated().insert(0, value);
                    });

                    setState(() {
                      if ((value.image ?? "").isEmpty) {
                        snack(
                            "Failed to receive any images from the server. Please try again later.");
                      }
                      setState(() {
                        loading = false;
                      });
                    });
                  });
                }
              },
              child: loading
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.auto_awesome_rounded),
            ),
            body: CustomScrollView(
              slivers: [
                SliverList(
                    delegate: SliverChildListDelegate([
                  PaddingAll(
                      padding: 14,
                      child: Row(
                        children: [
                          PaddingRight(
                              padding: 14,
                              child: initImageUrl != null
                                  ? InkWell(
                                      borderRadius: BorderRadius.circular(24),
                                      onLongPress: () => setState(() {
                                        initImageUrl = null;
                                      }),
                                      onTap: () => setState(() {
                                        Clipboard.getData("text/plain")
                                            .then((value) {
                                          setState(() {
                                            initImageUrl = value?.text ?? "";
                                          });
                                        });
                                      }),
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          child: Image.network(
                                            initImageUrl!,
                                            width: 129,
                                            height: 129,
                                            fit: BoxFit.cover,
                                          )),
                                    )
                                  : ElevatedButton(
                                      child: const Text("Image URL"),
                                      onPressed: () {
                                        Clipboard.getData("text/plain")
                                            .then((value) {
                                          if (value != null) {
                                            setState(() {
                                              initImageUrl = value.text ?? "";
                                            });
                                          }
                                        });
                                      },
                                    )),
                          Flexible(
                              child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: prompt,
                                decoration: const InputDecoration(
                                    hintText: "Enter a prompt",
                                    border: OutlineInputBorder(),
                                    label: Text("Prompt")),
                              ),
                              PaddingTop(
                                  padding: 14,
                                  child: TextField(
                                      controller: negativePrompt,
                                      decoration: const InputDecoration(
                                          hintText: "Enter a negative prompt",
                                          border: OutlineInputBorder(),
                                          label: Text("Negative Prompt"))))
                            ],
                          ))
                        ],
                      )),
                  const PaddingAll(
                    padding: 14,
                    child: ExpansionTile(
                      title: Text("Advanced Configuration"),
                      children: [DiffusionSettings()],
                    ),
                  )
                ])),
                SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                        (context, index) => PaddingAll(
                              padding: 14,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.5),
                                          blurRadius: 36,
                                          spreadRadius: 12)
                                    ]),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(24),
                                  onLongPress: () => stableDiffusionService()
                                      .deleteDialog(context,
                                          data().getGenerated()[index].image!),
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ImageScreen(
                                                image: data()
                                                    .getGenerated()[index],
                                              ))).then((value) {
                                    if (value is GeneratedImage) {
                                      model = DiffusionModel()
                                        ..id = value.model
                                        ..name = value.model
                                        ..description = "Loaded";
                                      initImageUrl = value.promptImage;
                                      prompt.value = TextEditingValue(
                                          text: value.prompt ?? "");
                                      negativePrompt.value = TextEditingValue(
                                          text: value.negativePrompt ?? "");
                                      setState(() {});
                                    }
                                  }),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: Stack(
                                        children: [
                                          Image.network(
                                            data()
                                                .getGenerated()[index]
                                                .bestImage(),
                                            fit: BoxFit.cover,
                                          ),
                                          Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Blur(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(24),
                                                        topRight:
                                                            Radius.circular(
                                                                24)),
                                                blur: 14,
                                                blurColor: Colors.black,
                                                overlay: PromptDetails(
                                                  image: data()
                                                      .getGenerated()[index],
                                                ),
                                                child: Opacity(
                                                    opacity: 0,
                                                    child: PromptDetails(
                                                      image:
                                                          data().getGenerated()[
                                                              index],
                                                    ))),
                                          )
                                        ],
                                      )),
                                ),
                              ),
                            ),
                        childCount: data().getGenerated().length),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            MediaQuery.of(context).size.width ~/ 350))
              ],
            )),
      );
}
