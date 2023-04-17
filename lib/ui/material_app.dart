import 'package:ars_cognitio/model/chat/chat.dart';
import 'package:ars_cognitio/model/chat/chat_message.dart';
import 'package:ars_cognitio/sugar.dart';
import 'package:ars_cognitio/ui/home.dart';
import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart' as chat;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tinycolor2/tinycolor2.dart';

class ArsCognitioMaterialApp extends StatelessWidget {
  const ArsCognitioMaterialApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => GetMaterialApp(
        title: 'Ars Cognitio',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(useMaterial3: true).copyWith(),
        darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
          useMaterial3: true,
          splashFactory: InkSparkle.splashFactory,
          listTileTheme: const ListTileThemeData(
              dense: false, visualDensity: VisualDensity.compact),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              elevation: 0,
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              enableFeedback: false,
              showUnselectedLabels: false),
        ),
        home: const HomeScreen(),
      );
}

class MarkdownText extends StatelessWidget {
  final String content;

  const MarkdownText({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) => MarkdownBody(
        data: content,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          pPadding: EdgeInsets.only(top: 5, bottom: 5),
          tableBorder: TableBorder.all(
              borderRadius: BorderRadius.circular(7),
              width: 1,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .color!
                  .withOpacity(0.5)),
        ),
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
          title: ListTile(
            title: Text(widget.conversation.title ?? "Untitled"),
            subtitle: Text(chatService().tkSummary()),
          ),
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
                  child: Shimmer(
                      gradient: LinearGradient(colors: [
                        Theme.of(context).textTheme.bodyMedium!.color!,
                        Theme.of(context).textTheme.bodyMedium!.color!,
                        Theme.of(context).textTheme.bodyMedium!.color!,
                        Theme.of(context).textTheme.bodyMedium!.color!,
                        ColorTween(
                                begin: Colors.indigoAccent,
                                end: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color!)
                            .lerp(0.5)!,
                        ColorTween(
                                begin: Colors.deepPurpleAccent,
                                end: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color!)
                            .lerp(0.5)!,
                        ColorTween(
                                begin: Colors.purpleAccent,
                                end: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color!)
                            .lerp(0.5)!,
                        Theme.of(context).textTheme.bodyMedium!.color!,
                        Theme.of(context).textTheme.bodyMedium!.color!,
                        Theme.of(context).textTheme.bodyMedium!.color!,
                        Theme.of(context).textTheme.bodyMedium!.color!,
                      ]),
                      period: Duration(seconds: 3),
                      child: MarkdownText(content: snap.data ?? "...")),
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
