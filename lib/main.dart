import 'package:ars_cognitio/chameleon.dart';
import 'package:ars_cognitio/services/ai_service.dart';
import 'package:ars_cognitio/services/credential_service.dart';
import 'package:ars_cognitio/services/gcp_service.dart';
import 'package:ars_cognitio/services/openai_service.dart';
import 'package:ars_cognitio/sugar.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';

late Box<dynamic> box;

void main() => _init().then((_) => runApp(ChameleonPlatform.get().app));

Future<void> _init() async {
  box = await hive("config");
  services().register(() => AIService());
  services().register(() => CredentialService());
  services().register(() => GoogleCloudService());
  services().register(() => OpenAIService());
}
