import 'package:ars_cognitio/model/diffusion_model.dart';
import 'package:ars_cognitio/sugar.dart';
import 'package:ars_cognitio/ui/image.dart';
import 'package:dialoger/dialoger.dart';
import 'package:flutter/material.dart';
import 'package:padded/padded.dart';

class DiffusionScreen extends StatefulWidget {
  const DiffusionScreen({Key? key}) : super(key: key);

  @override
  State<DiffusionScreen> createState() => _DiffusionScreenState();
}

class _DiffusionScreenState extends State<DiffusionScreen> {
  TextEditingController controller = TextEditingController();
  TextEditingController prompt = TextEditingController();
  TextEditingController negativePrompt = TextEditingController();
  DiffusionModel model = stableDiffusionService().defaultModel;
  bool enhancePrompt = true;
  bool safetyChecker = false;
  double promptStrength = 0.85;
  double guidanceScale = 11.5;
  int inferenceSteps = 50;
  int width = 800;
  int height = 800;
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
                            value: e, label: e.name ?? "Unnamed Model?"))
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
                  await stableDiffusionService()
                      .text2Image(
                          model: model,
                          prompt: prompt.text,
                          enhancePrompt: enhancePrompt,
                          width: width,
                          height: height,
                          inferenceSteps: inferenceSteps,
                          guidanceScale: guidanceScale,
                          promptStrength: promptStrength,
                          safetyChecker: safetyChecker,
                          negativePrompt: negativePrompt.text)
                      .then((value) => setState(() {
                            saveData((d) {
                              for (var i in value.reversed) {
                                d.getGenerated().insert(0, i);
                              }
                            });
                          }));
                },
                child: const Icon(Icons.auto_awesome_rounded),
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
                              value: safetyChecker,
                              onChanged: (b) => setState(() {
                                    safetyChecker = b;
                                  })),
                          SwitchListTile(
                              title: Text("Prompt Enhancer"),
                              value: enhancePrompt,
                              onChanged: (b) => setState(() {
                                    enhancePrompt = b;
                                  })),
                          ListTile(
                            title: Text("Width $width"),
                            subtitle: Slider(
                                value: width.toDouble(),
                                label: width.toString(),
                                divisions: 800,
                                max: 800,
                                min: 2,
                                onChanged: (d) => setState(() {
                                      width = d.round();
                                    })),
                          ),
                          ListTile(
                            title: Text("Height $height"),
                            subtitle: Slider(
                                value: height.toDouble(),
                                label: height.toString(),
                                divisions: 800,
                                max: 800,
                                min: 2,
                                onChanged: (d) => setState(() {
                                      height = d.round();
                                    })),
                          ),
                          ListTile(
                            title: Text(
                                "Prompt Strength ${(promptStrength * 100).toInt()}%"),
                            subtitle: Slider(
                                value: promptStrength,
                                label: "${(promptStrength * 100).toInt()}%",
                                max: 1,
                                min: 0,
                                divisions: 100,
                                onChanged: (d) => setState(() {
                                      promptStrength = d;
                                    })),
                          ),
                          ListTile(
                            title: Text("Inference Steps $inferenceSteps"),
                            subtitle: Slider(
                                value: inferenceSteps.toDouble(),
                                label: inferenceSteps.toString(),
                                max: 50,
                                min: 0,
                                divisions: 50,
                                onChanged: (d) => setState(() {
                                      inferenceSteps = d.round();
                                    })),
                          ),
                          ListTile(
                            title: Text(
                                "Guidance Scale ${guidanceScale.toStringAsFixed(1)}"),
                            subtitle: Slider(
                                value: guidanceScale,
                                label: guidanceScale.toStringAsFixed(1),
                                divisions: 200,
                                max: 20,
                                min: 0,
                                onChanged: (d) => setState(() {
                                      guidanceScale = d;
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
                                    data().getGenerated()[index])),
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
