import 'package:flutter/material.dart';

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

class HomeMaterial extends StatelessWidget {
  const HomeMaterial({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Text("Material"),
        ),
      );
}
