import 'package:ars_cognitio/model/settings.dart';
import 'package:ars_cognitio/sugar.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: ListView(
          children: [
            ListTile(
                title: const Text("Open AI"),
                subtitle: TextField(
                  decoration: const InputDecoration(
                    hintText: "<enter key>",
                  ),
                  controller: TextEditingController(
                    text: openaiService().getKey(),
                  ),
                  maxLines: 1,
                  maxLength: 100,
                  onSubmitted: (e) => openaiService().setKey(e),
                  onChanged: (e) => openaiService().setKey(e),
                )),
            ListTile(
                title: const Text("Open AI Organization"),
                subtitle: TextField(
                  decoration: const InputDecoration(hintText: "(optional)"),
                  controller: TextEditingController(
                    text: openaiService().getOrg(),
                  ),
                  maxLines: 1,
                  maxLength: 100,
                  onSubmitted: (e) => openaiService().setOrg(e),
                  onChanged: (e) => openaiService().setOrg(e),
                )),
            ListTile(
                title: const Text("Stable Diffusion API Key"),
                subtitle: TextField(
                  decoration: const InputDecoration(hintText: "<enter key>"),
                  controller: TextEditingController(
                    text: stableDiffusionService().getKey(),
                  ),
                  maxLines: 1,
                  maxLength: 100,
                  onSubmitted: (e) => stableDiffusionService().setKey(e),
                  onChanged: (e) => stableDiffusionService().setKey(e),
                )),
            ListTile(
              title: Text("Chat Model"),
              subtitle: DropdownMenu<String>(
                dropdownMenuEntries: [
                  ...availableChatModels.map((e) => DropdownMenuEntry(
                        value: e,
                        label: e,
                      ))
                ],
                initialSelection:
                    data().getSettings().chatModel ?? availableChatModels.first,
                onSelected: (e) =>
                    saveData((d) => d.getSettings().chatModel = e),
              ),
            ),
            ListTile(
              title: Text("Chat Temperature"),
              subtitle: Slider(
                  value: (data().getSettings().chatTemperature ?? 1).toDouble(),
                  label: (data().getSettings().chatTemperature ?? 1).toString(),
                  divisions: 100,
                  max: 1,
                  min: 0,
                  onChanged: (d) => setState(() {
                        saveData((dx) {
                          dx.getSettings().chatTemperature = d;
                        });
                      })),
            ),
            ListTile(
              title: Text("Chat Presence Penalty"),
              subtitle: Slider(
                  value: (data().getSettings().presencePenalty ?? 0).toDouble(),
                  label: (data().getSettings().presencePenalty ?? 0).toString(),
                  divisions: 400,
                  max: 2,
                  min: -2,
                  onChanged: (d) => setState(() {
                        saveData((dx) {
                          dx.getSettings().presencePenalty = d;
                        });
                      })),
            ),
            ListTile(
              title: Text("Chat Frequency Penalty"),
              subtitle: Slider(
                  value:
                      (data().getSettings().frequencyPenalty ?? 0).toDouble(),
                  label:
                      (data().getSettings().frequencyPenalty ?? 0).toString(),
                  divisions: 400,
                  max: 2,
                  min: -2,
                  onChanged: (d) => setState(() {
                        saveData((dx) {
                          dx.getSettings().frequencyPenalty = d;
                        });
                      })),
            ),
          ],
        ),
      );
}
