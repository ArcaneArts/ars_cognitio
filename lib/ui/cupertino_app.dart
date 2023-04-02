import 'package:flutter/cupertino.dart';

class ArsCognitioCupertinoApp extends StatelessWidget {
  const ArsCognitioCupertinoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const CupertinoApp(
        title: 'Ars Cognitio',
        home: HomeCupertino(),
      );
}

class HomeCupertino extends StatelessWidget {
  const HomeCupertino({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const CupertinoPageScaffold(
          child: Center(
        child: Text("Cupertino"),
      ));
}
