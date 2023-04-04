import 'package:ars_cognitio/model/chat/chat.dart';
import 'package:ars_cognitio/model/chat/chat_message.dart';
import 'package:ars_cognitio/sugar.dart';
import 'package:dart_openai/openai.dart';
import 'package:dialoger/dialoger.dart';
import 'package:fast_log/fast_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart' as chat;
import 'package:foil/foil.dart';
import 'package:tinycolor2/tinycolor2.dart';

class ArsCognitioMaterialApp extends StatelessWidget {
  const ArsCognitioMaterialApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Ars Cognitio',
        theme: ThemeData.light(useMaterial3: true).copyWith(),
        darkTheme: ThemeData.dark(useMaterial3: true).copyWith(),
        home: const HomeMaterial(),
      );
}

class HomeMaterial extends StatefulWidget {
  const HomeMaterial({Key? key}) : super(key: key);

  @override
  State<HomeMaterial> createState() => _HomeMaterialState();
}

class _HomeMaterialState extends State<HomeMaterial> {
  int index = 1;

  @override
  Widget build(BuildContext context) => Scaffold(
      body: index == 0
          ? const ToolsMaterial()
          : index == 1
              ? const ChatMaterial()
              : const MoreMaterial(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (int index) => setState(() => this.index = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline_rounded),
            activeIcon: Icon(Icons.work_rounded),
            label: "Tools",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            activeIcon: Icon(Icons.chat_bubble_rounded),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.label_outline_rounded),
            activeIcon: Icon(Icons.label_rounded),
            label: "More",
          ),
        ],
      ));
}

class ToolsMaterial extends StatelessWidget {
  const ToolsMaterial({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: ListView(
          children: [
            ListTile(
              title: Text("Text to Image"),
              subtitle: Text("Generate an Image from a prompt"),
            ),
            ListTile(
              title: Text("Image to Image"),
              subtitle: Text("Generate an Image from an Image & Prompt"),
            ),
            ListTile(
              title: Text("Inpaint Image"),
              subtitle: Text("Generate an Image from a Mask & Prompt"),
            )
          ],
        ),
      );
}

class ChatMaterial extends StatefulWidget {
  const ChatMaterial({Key? key}) : super(key: key);

  @override
  State<ChatMaterial> createState() => _ChatMaterialState();
}

class _ChatMaterialState extends State<ChatMaterial> {
  @override
  Widget build(BuildContext context) => Scaffold(
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add_rounded),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatViewScreenMaterial(
                        conversation: chatService().newChat())))),
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

class MoreMaterial extends StatelessWidget {
  const MoreMaterial({Key? key}) : super(key: key);

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
          ],
        ),
      );
}

class MarkdownText extends StatelessWidget {
  final String content;

  const MarkdownText({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) => MarkdownBody(
        data: content,
        selectable: true,
      );
}

class ChatViewScreenMaterial extends StatefulWidget {
  final Chat conversation;

  const ChatViewScreenMaterial({Key? key, required this.conversation})
      : super(key: key);

  @override
  State<ChatViewScreenMaterial> createState() => _ChatViewScreenMaterialState();
}

class _ChatViewScreenMaterialState extends State<ChatViewScreenMaterial> {
  Stream<String?>? responseStream;

  void send(ChatMessage message) {
    setState(() {
      if (message.message!.startsWith("/system ")) {
        message = ChatMessage.create(
            message: message.message!.substring(8),
            role: OpenAIChatMessageRole.system);
      }

      responseStream = chatService().addMessage(widget.conversation, message);
      responseStream = responseStream?.map((event) {
        if (event == null) {
          responseStream = null;
          setState(() {});
        }

        return event;
      });

      setState(() {});
    });
  }

  Iterable<types.Message> buildMessages() sync* {
    int id = 0;
    for (ChatMessage i in (widget.conversation.messages ?? [])) {
      if (i.role == OpenAIChatMessageRole.system) {
        yield types.SystemMessage(
          id: "$id",
          text: i.message ?? "",
        );
      } else if (i.role == OpenAIChatMessageRole.user) {
        yield types.TextMessage(
          id: "$id",
          text: i.message ?? "",
          author: const types.User(id: "user", firstName: "You"),
        );
      } else {
        yield types.TextMessage(
            id: "$id",
            text: i.message ?? "",
            author: const types.User(id: "assistant", firstName: "Assistant"));
      }

      id++;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.conversation.title ?? "Untitled"),
        ),
        body: chat.Chat(
          messages: [
            ...buildMessages(),
            if (responseStream != null)
              types.TextMessage(
                id: "${widget.conversation.messages?.length ?? 0}",
                text: "...",
                author: const types.User(id: "stream", firstName: "Assistant"),
              )
          ].reversed.toList(),
          theme: Theme.of(context).brightness == Brightness.dark
              ? chat.DarkChatTheme(
                  primaryColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .desaturate(75)
                      .darken(55),
                  secondaryColor: Theme.of(context)
                      .colorScheme
                      .secondary
                      .desaturate(15)
                      .darken(55),
                  inputBackgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .desaturate(75)
                      .darken(55),
                  backgroundColor: Theme.of(context).colorScheme.background)
              : chat.DefaultChatTheme(
                  primaryColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .brighten(25)
                      .desaturate(25),
                  secondaryColor:
                      Theme.of(context).colorScheme.secondary.brighten(40),
                  inputBackgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .brighten(25)
                      .desaturate(25),
                  inputTextColor:
                      Theme.of(context).textTheme.bodyMedium!.color!,
                  backgroundColor: Theme.of(context).colorScheme.background),
          textMessageBuilder: (message,
              {required messageWidth, required showName}) {
            if (responseStream != null && message.author.id == "stream") {
              return StreamBuilder<String?>(
                stream: responseStream!,
                builder: (context, snap) => Padding(
                  padding: const EdgeInsets.all(14),
                  child: MarkdownText(content: snap.data ?? "..."),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(14),
              child: MarkdownText(content: message.text),
            );
          },
          onSendPressed: (message) {
            send(ChatMessage.create(
              message: message.text,
              role: OpenAIChatMessageRole.user,
            ));
          },
          user: const types.User(id: "user", firstName: "You"),
        ),
      );
}
