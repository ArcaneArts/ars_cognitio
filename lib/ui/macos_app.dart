import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

class ArsCognitioMacosApp extends StatelessWidget {
  const ArsCognitioMacosApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const MacosApp(
        title: 'Ars Cognitio',
        home: HomeMacos(),
      );
}

class HomeMacos extends StatelessWidget {
  const HomeMacos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const MacosWindow(
        child: Center(
          child: Text("MacOS"),
        ),
      );
}
