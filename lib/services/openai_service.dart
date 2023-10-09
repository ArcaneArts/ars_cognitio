import 'package:ars_cognitio/sugar.dart';
import 'package:dart_openai/dart_openai.dart';

class OpenAIService extends ArsCognitioStatelessService {
  String getKey() => data().getSettings().openAiKey ?? "";

  void setKey(String key) => saveData((d) => d.getSettings().openAiKey = key);

  String? getOrg() => data().getSettings().openAiOrganization;

  void setOrg(String org) =>
      saveData((d) => d.getSettings().openAiOrganization = org);

  OpenAI client() {
    OpenAI.apiKey = getKey();
    OpenAI.organization = getOrg();
    return OpenAI.instance;
  }
}
