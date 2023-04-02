import 'package:ars_cognitio/sugar.dart';
import 'package:dart_openai/openai.dart';

class OpenAIService extends ArsCognitioStatelessService {
  String _key() => credentialService().get("openai") ?? "";
  String? _org() => credentialService().get("openai.org");

  OpenAI client() {
    OpenAI.apiKey = _key();
    OpenAI.organization = _org();
    return OpenAI.instance;
  }
}
