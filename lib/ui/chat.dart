import 'package:ars_cognitio/sugar.dart';
import 'package:ars_cognitio/ui/conversation.dart';
import 'package:ars_cognitio/ui/settings.dart';
import 'package:dialoger/dialoger.dart';
import 'package:flutter/material.dart';
import 'package:padded/padded.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Chat"),
          actions: [
            IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatViewScreenMaterial(
                                conversation: chatService().newChat())))
                    .then((value) => setState(() {}))),
            PaddingRight(
                padding: 14,
                child: IconButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingsScreen())),
                    icon: const Icon(Icons.settings_rounded))),
          ],
        ),
        body: ListView.builder(
          itemCount: chatService().getChats().length,
          itemBuilder: (context, index) => chatService().getChats().length >
                  index
              ? ListTile(
                  onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatViewScreenMaterial(
                                  conversation:
                                      chatService().getChats()[index])))
                      .then((value) => setState(() {})),
                  subtitle: Text((chatService()
                                  .getChats()[index]
                                  .messages
                                  ?.length ??
                              0) >
                          0
                      ? "${chatService().getChats()[index].messages!.length} Messages"
                      : "No messages"),
                  trailing: IconButton(
                      icon: const Icon(Icons.delete_rounded),
                      onPressed: () => dialogConfirm(
                          context: context,
                          title: "Delete Chat?",
                          description:
                              "Are you sure you want to delete ${chatService().getChats()[index].title ?? "New Chat"}?",
                          confirmButtonText: "Delete",
                          onConfirm: (context) {
                            setState(() {
                              chatService().deleteChat(
                                  chatService().getChats()[index].uuid!);
                            });
                          })),
                  title:
                      Text(chatService().getChats()[index].title ?? "Untitled"),
                )
              : const SizedBox(
                  height: 0,
                ),
        ),
      );
}
