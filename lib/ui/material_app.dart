import 'package:ars_cognitio/ui/chat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        home: const ChatsScreen(),
      );
}
