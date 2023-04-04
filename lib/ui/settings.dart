import 'package:ars_cognitio/sugar.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

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
                ))
          ],
        ),
      );
}
