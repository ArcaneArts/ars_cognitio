import 'package:fluent_ui/fluent_ui.dart';

class ArsCognitioFluentApp extends StatelessWidget {
  const ArsCognitioFluentApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const FluentApp(
        title: 'Ars Cognitio',
        home: HomeFluent(),
      );
}

class HomeFluent extends StatelessWidget {
  const HomeFluent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const NavigationView(
          content: Center(
        child: Text("Windows"),
      ));
}
