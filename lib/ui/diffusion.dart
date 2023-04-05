import 'package:ars_cognitio/model/diffusion_model.dart';
import 'package:ars_cognitio/sugar.dart';
import 'package:ars_cognitio/ui/image.dart';
import 'package:dialoger/dialoger.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) => DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          actions: [
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
                              icon: Icon(Icons.info_rounded),
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
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.text_fields_rounded), text: "Text to Image"),
              Tab(icon: Icon(Icons.image_rounded), text: "Image to Image"),
              Tab(icon: Icon(Icons.format_paint_rounded), text: "Inpainting"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  setState(() {
                    loading = true;
                  });
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
                      for (var i in value.reversed) {
                        d.getGenerated().insert(0, i);
                      }
                    });

                    setState(() {
                      if (value.isEmpty) {
                        snack(
                            "Failed to receive any images from the server. Please try again later.");
                      }
                      setState(() {
                        loading = false;
                      });
                    });
                  });
                },
                child: loading
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.auto_awesome_rounded),
              ),
              body: Padding(
                padding: EdgeInsets.all(14),
                child: ListView(
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
                                label: Text("Negative Prompt")))),
                    PaddingTop(
                      padding: 14,
                      child: ExpansionTile(
                        title: Text("Advanced Configuration"),
                        children: [
                          SwitchListTile(
                              title: Text("Safetey Checker"),
                              value: data().getSettings().safetyChecker ?? true,
                              onChanged: (b) => setState(() {
                                    saveData((d) =>
                                        d.getSettings().safetyChecker = b);
                                  })),
                          SwitchListTile(
                              title: Text("Prompt Enhancer"),
                              value: data().getSettings().enhancePrompt ?? true,
                              onChanged: (b) => setState(() {
                                    saveData((d) =>
                                        d.getSettings().enhancePrompt = b);
                                  })),
                          ListTile(
                            title: Text(
                                "Width ${(data().getSettings().width ?? 512)}"),
                            subtitle: Slider(
                                value: (data().getSettings().width ?? 512)
                                    .toDouble(),
                                label: (data().getSettings().width ?? 512)
                                    .toString(),
                                divisions: 800,
                                max: 800,
                                min: 2,
                                onChanged: (d) => setState(() {
                                      saveData((dx) {
                                        int width = d.round();
                                        width = (width ~/ 8) * 8;
                                        width = width < 8 ? 8 : width;
                                        dx.getSettings().width = width;
                                      });
                                    })),
                          ),
                          ListTile(
                            title: Text(
                                "Height ${(data().getSettings().height ?? 512)}"),
                            subtitle: Slider(
                                value: (data().getSettings().height ?? 512)
                                    .toDouble(),
                                label: (data().getSettings().height ?? 512)
                                    .toString(),
                                divisions: 800,
                                max: 800,
                                min: 2,
                                onChanged: (d) => setState(() {
                                      saveData((dx) {
                                        int height = d.round();
                                        height = (height ~/ 8) * 8;
                                        height = height < 8 ? 8 : height;
                                        dx.getSettings().height = height;
                                      });
                                    })),
                          ),
                          ListTile(
                            title: Text(
                                "Prompt Strength ${((data().getSettings().promptStrength ?? 0.85) * 100).toInt()}%"),
                            subtitle: Slider(
                                value:
                                    data().getSettings().promptStrength ?? 0.85,
                                label:
                                    "${((data().getSettings().promptStrength ?? 0.85) * 100).toInt()}%",
                                max: 1,
                                min: 0,
                                divisions: 100,
                                onChanged: (d) => setState(() {
                                      saveData((dx) =>
                                          dx.getSettings().promptStrength = d);
                                    })),
                          ),
                          ListTile(
                            title: Text(
                                "Inference Steps ${(data().getSettings().inferenceSteps ?? 50)}"),
                            subtitle: Slider(
                                value:
                                    (data().getSettings().inferenceSteps ?? 50)
                                        .toDouble(),
                                label:
                                    (data().getSettings().inferenceSteps ?? 50)
                                        .toString(),
                                max: 50,
                                min: 0,
                                divisions: 50,
                                onChanged: (d) => setState(() {
                                      saveData((dx) => dx
                                          .getSettings()
                                          .inferenceSteps = d.round());
                                    })),
                          ),
                          ListTile(
                            title: Text(
                                "Guidance Scale ${(data().getSettings().guidanceScale ?? 7.5).toStringAsFixed(1)}"),
                            subtitle: Slider(
                                value:
                                    (data().getSettings().guidanceScale ?? 7.5),
                                label:
                                    (data().getSettings().guidanceScale ?? 7.5)
                                        .toStringAsFixed(1),
                                divisions: 200,
                                max: 20,
                                min: 0,
                                onChanged: (d) => setState(() {
                                      saveData((dx) =>
                                          dx.getSettings().guidanceScale = d);
                                    })),
                          )
                        ],
                      ),
                    ),
                    PaddingVertical(
                      padding: 14,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                MediaQuery.of(context).size.width ~/ 350),
                        itemBuilder: (context, index) => PaddingAll(
                          padding: 7,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onLongPress: () => dialogConfirm(
                                context: context,
                                title: "Delete?",
                                description: "Are you sure?",
                                confirmButtonText: "Delete",
                                onConfirm: (context) => setState(() {
                                      saveData((d) {
                                        d.getGenerated().removeAt(index);
                                      });
                                    })),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ImageScreen(
                                          image: data().getGenerated()[index],
                                        ))),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.network(
                                  data().getGenerated()[index],
                                  fit: BoxFit.cover,
                                )),
                          ),
                        ),
                        itemCount: data().getGenerated().length,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Text("NYI"),
            Text("NYI"),
          ],
        ),
      ));
}
