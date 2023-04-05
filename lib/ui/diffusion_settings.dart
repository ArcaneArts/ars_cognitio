import 'package:ars_cognitio/sugar.dart';
import 'package:flutter/material.dart';

class DiffusionSettings extends StatefulWidget {
  const DiffusionSettings({Key? key}) : super(key: key);

  @override
  State<DiffusionSettings> createState() => _DiffusionSettingsState();
}

class _DiffusionSettingsState extends State<DiffusionSettings> {
  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
              title: const Text("Safety Checker"),
              value: data().getSettings().safetyChecker ?? true,
              onChanged: (b) => setState(() {
                    saveData((d) => d.getSettings().safetyChecker = b);
                  })),
          SwitchListTile(
              title: const Text("Prompt Enhancer"),
              value: data().getSettings().enhancePrompt ?? true,
              onChanged: (b) => setState(() {
                    saveData((d) => d.getSettings().enhancePrompt = b);
                  })),
          ListTile(
            title: Text("Width ${(data().getSettings().width ?? 512)}"),
            subtitle: Slider(
                value: (data().getSettings().width ?? 512).toDouble(),
                label: (data().getSettings().width ?? 512).toString(),
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
            title: Text("Height ${(data().getSettings().height ?? 512)}"),
            subtitle: Slider(
                value: (data().getSettings().height ?? 512).toDouble(),
                label: (data().getSettings().height ?? 512).toString(),
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
                value: data().getSettings().promptStrength ?? 0.85,
                label:
                    "${((data().getSettings().promptStrength ?? 0.85) * 100).toInt()}%",
                max: 1,
                min: 0,
                divisions: 100,
                onChanged: (d) => setState(() {
                      saveData((dx) => dx.getSettings().promptStrength = d);
                    })),
          ),
          ListTile(
            title: Text(
                "Inference Steps ${(data().getSettings().inferenceSteps ?? 50)}"),
            subtitle: Slider(
                value: (data().getSettings().inferenceSteps ?? 50).toDouble(),
                label: (data().getSettings().inferenceSteps ?? 50).toString(),
                max: 50,
                min: 0,
                divisions: 50,
                onChanged: (d) => setState(() {
                      saveData(
                          (dx) => dx.getSettings().inferenceSteps = d.round());
                    })),
          ),
          ListTile(
            title: Text(
                "Guidance Scale ${(data().getSettings().guidanceScale ?? 7.5).toStringAsFixed(1)}"),
            subtitle: Slider(
                value: (data().getSettings().guidanceScale ?? 7.5),
                label: (data().getSettings().guidanceScale ?? 7.5)
                    .toStringAsFixed(1),
                divisions: 200,
                max: 20,
                min: 0,
                onChanged: (d) => setState(() {
                      saveData((dx) => dx.getSettings().guidanceScale = d);
                    })),
          )
        ],
      );
}
