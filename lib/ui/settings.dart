import 'package:ars_cognitio/model/playht_voice.dart';
import 'package:ars_cognitio/model/settings.dart';
import 'package:ars_cognitio/ui/play_stream.dart';
import 'package:ars_cognitio/sugar.dart';
import 'package:dialoger/dialoger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
              leading: const Icon(Icons.key_rounded),
              title: const Text("API Keys"),
              onTap: () => Get.to(() => const SettingsAPIKeys()),
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_rounded),
              title: const Text("Chat Settings"),
              onTap: () => Get.to(() => const SettingsChat()),
              subtitle: Text(chatService().tkSummary()),
            ),
            ListTile(
              title: const Text("Play.ht Voice"),
              subtitle: Text(data().getSettings().playhtVoice ?? "Unset"),
              onTap: () => Get.to(() => const PlayhtVoicePicker()),
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded),
              title: const Text("Quick Wipe"),
              onTap: () => dialogConfirm(
                  context: context,
                  title: "Quick Wipe?",
                  description:
                      "This will retain generated images on the server.",
                  confirmButtonText: "Wipe",
                  onConfirm: (context) {
                    saveData((d) => d.getGenerated().clear());
                  }),
            )
          ],
        ),
      );
}

class PlayhtVoicePicker extends StatelessWidget {
  const PlayhtVoicePicker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Playht Voice"),
        ),
        body: FutureBuilder<List<PlayhtVoice>>(
          future: playhtService().getUHDVoices(),
          builder: (context, snap) => snap.hasData
              ? ListView.builder(
                  itemCount: snap.data!.length,
                  itemBuilder: (context, pos) => ListTile(
                    leading: IgnorePointer(
                      ignoring: true,
                      child: Radio<String?>(
                        value: snap.data![pos].id ?? "",
                        groupValue: data().getSettings().playhtVoice,
                        onChanged: (e) {},
                      ),
                    ),
                    onTap: () {
                      saveData((d) =>
                          d.getSettings().playhtVoice = snap.data![pos].id);
                      Navigator.pop(context);
                    },
                    subtitle: Text(snap.data![pos].id ?? ""),
                    trailing: PlayStreamer(
                        playing: IconButton(
                          icon: Icon(Icons.stop_rounded),
                          onPressed: () => audioService().stopper(),
                        ),
                        notPlaying: IconButton(
                          icon: Icon(Icons.play_arrow_rounded),
                          onPressed: () => audioService()
                              .playMedia(snap.data![pos].sample ?? ""),
                        )),
                    title: Text(snap.data![pos].name ?? "Unknown Name"),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      );
}

class SettingsChat extends StatefulWidget {
  const SettingsChat({Key? key}) : super(key: key);

  @override
  State<SettingsChat> createState() => _SettingsChatState();
}

class _SettingsChatState extends State<SettingsChat> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Chat Settings"),
        ),
        body: ListView(
          children: [
            ListTile(
              title: const Text("Chat Model"),
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
              title: const Text("Chat Temperature"),
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
              title: const Text("Chat Presence Penalty"),
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
              title: const Text("Chat Frequency Penalty"),
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

class SettingsAPIKeys extends StatefulWidget {
  const SettingsAPIKeys({Key? key}) : super(key: key);

  @override
  State<SettingsAPIKeys> createState() => _SettingsAPIKeysState();
}

class _SettingsAPIKeysState extends State<SettingsAPIKeys> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("API Keys"),
        ),
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
                title: const Text("Play.ht User"),
                subtitle: TextField(
                  decoration: const InputDecoration(hintText: "<enter user>"),
                  controller: TextEditingController(
                    text: playhtService().user(),
                  ),
                  maxLines: 1,
                  maxLength: 100,
                  onSubmitted: (e) => playhtService().setUser(e),
                  onChanged: (e) => playhtService().setUser(e),
                )),
            ListTile(
                title: const Text("Play.ht Secret"),
                subtitle: TextField(
                  decoration: const InputDecoration(hintText: "<enter secret>"),
                  controller: TextEditingController(
                    text: playhtService().secret(),
                  ),
                  maxLines: 1,
                  maxLength: 100,
                  onSubmitted: (e) => playhtService().setSecret(e),
                  onChanged: (e) => playhtService().setSecret(e),
                )),
          ],
        ),
      );
}
