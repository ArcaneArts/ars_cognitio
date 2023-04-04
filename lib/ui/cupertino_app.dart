import 'package:ars_cognitio/model/chat/chat.dart';
import 'package:ars_cognitio/model/chat/chat_message.dart';
import 'package:ars_cognitio/sugar.dart';
import 'package:ars_cognitio/ui/material_app.dart';
import 'package:dart_openai/openai.dart';
import 'package:dialoger/dialoger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart' as chat;
import 'package:tinycolor2/tinycolor2.dart';

class ArsCognitioCupertinoApp extends StatelessWidget {
  const ArsCognitioCupertinoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => CupertinoApp(
        color: Colors.deepPurpleAccent,
        title: 'Ars Cognitio',
        home: HomeCupertino(),
        theme: CupertinoThemeData(
          primaryColor: Colors.deepPurpleAccent,
        ),
        localizationsDelegates: [
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
      );
}

class HomeCupertino extends StatelessWidget {
  const HomeCupertino({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => CupertinoTabScaffold(
        tabBuilder: (context, index) {
          if (index == 1) {
            return const ChatCupertino();
          }
          if (index == 2) {
            return const MoreCupertino();
          }
          return const Text("Derp");
        },
        controller: CupertinoTabController(initialIndex: 1),
        tabBar: CupertinoTabBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.archivebox),
              activeIcon: Icon(CupertinoIcons.archivebox_fill),
              label: 'Tools',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chat_bubble),
              activeIcon: Icon(CupertinoIcons.chat_bubble_fill),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.circle_grid_hex),
              activeIcon: Icon(CupertinoIcons.circle_grid_hex_fill),
              label: 'More',
            )
          ],
        ),
      );
}

class ChatCupertino extends StatefulWidget {
  const ChatCupertino({Key? key}) : super(key: key);

  @override
  State<ChatCupertino> createState() => _ChatCupertinoState();
}

class _ChatCupertinoState extends State<ChatCupertino> {
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: const Text("Chat"),
              trailing: IconButton(
                icon: const Icon(CupertinoIcons.add_circled_solid),
                onPressed: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => ChatViewScreenCupertino(
                              conversation: chatService().newChat())));
                },
              ),
            ),
            child: ListView.builder(
              itemCount: chatService().getChats().length,
              itemBuilder: (context, index) => chatService().getChats().length >
                      index
                  ? CupertinoListTile(
                      onTap: () => Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => ChatViewScreenCupertino(
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
                      title: Text(
                          chatService().getChats()[index].title ?? "Untitled"),
                    )
                  : const SizedBox(
                      height: 0,
                    ),
            )),
      );
}

class MoreCupertino extends StatelessWidget {
  const MoreCupertino({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
          child: ListView(
        children: [
          Text("Open AI",
              style: CupertinoTheme.of(context).textTheme.textStyle),
          CupertinoTextField(
            controller: TextEditingController(
              text: openaiService().getKey(),
            ),
            maxLines: 1,
            maxLength: 100,
            onSubmitted: (e) => openaiService().setKey(e),
            onChanged: (e) => openaiService().setKey(e),
          ),
          Text("Open AI Organization",
              style: CupertinoTheme.of(context).textTheme.textStyle),
          CupertinoTextField(
            controller: TextEditingController(
              text: openaiService().getOrg(),
            ),
            maxLines: 1,
            maxLength: 100,
            onSubmitted: (e) => openaiService().setOrg(e),
            onChanged: (e) => openaiService().setOrg(e),
          )
        ],
      ));
}

class ChatViewScreenCupertino extends StatefulWidget {
  final Chat conversation;

  const ChatViewScreenCupertino({Key? key, required this.conversation})
      : super(key: key);

  @override
  State<ChatViewScreenCupertino> createState() =>
      _ChatViewScreenCupertinoState();
}

class _ChatViewScreenCupertinoState extends State<ChatViewScreenCupertino> {
  Stream<String?>? responseStream;

  void send(ChatMessage message) {
    setState(() {
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
  Widget build(BuildContext context) => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(widget.conversation.title ?? "Untitled"),
        ),
        child: Material(
          color: Colors.transparent,
          child: chat.Chat(
            messages: [
              ...buildMessages(),
              if (responseStream != null)
                types.TextMessage(
                  id: "${widget.conversation.messages?.length ?? 0}",
                  text: "...",
                  author:
                      const types.User(id: "stream", firstName: "Assistant"),
                )
            ].reversed.toList(),
            theme: chat.DarkChatTheme(),
            textMessageBuilder: (message,
                {required messageWidth, required showName}) {
              if (responseStream != null && message.author.id == "stream") {
                return StreamBuilder<String?>(
                  stream: responseStream!,
                  builder: (context, snap) => Padding(
                    padding: const EdgeInsets.all(14),
                    child: Theme(
                        data: ThemeData.dark(),
                        child: MarkdownText(content: snap.data ?? "...")),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(14),
                child: Theme(
                  data: ThemeData.dark(),
                  child: MarkdownText(content: message.text),
                ),
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
        ),
      );
}
