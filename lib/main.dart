import 'dart:async';

import 'package:ars_cognitio/services/ai_service.dart';
import 'package:ars_cognitio/services/chat_service.dart';
import 'package:ars_cognitio/services/data_service.dart';
import 'package:ars_cognitio/services/diffusion_service.dart';
import 'package:ars_cognitio/services/gcp_service.dart';
import 'package:ars_cognitio/services/openai_service.dart';
import 'package:ars_cognitio/sugar.dart';
import 'package:ars_cognitio/ui/material_app.dart';
import 'package:fast_log/fast_log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

late Box<dynamic> box;

void main() => _init().then((_) =>
    runZonedGuarded(() => runApp(const ArsCognitioMaterialApp()), (e, stack) {
      error(e);
      error(stack);
    }));

Future<void> _init() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    String path = (await getApplicationDocumentsDirectory()).path;
    Hive.init(path);
    success("Initialized Non-Web Hive storage location: $path");
  }

  box = await hive("data");
  services().register(() => DataService(), lazy: false);
  services().register(() => AIService());
  services().register(() => GoogleCloudService());
  services().register(() => OpenAIService());
  services().register(() => ChatService());
  services().register(() => DiffusionService());
}
