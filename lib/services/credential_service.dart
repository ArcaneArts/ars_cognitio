import 'package:ars_cognitio/main.dart';
import 'package:ars_cognitio/sugar.dart';

class CredentialService extends ArsCognitioStatelessService {
  String? get(String key) => box.get("credential.$key");

  bool has(String key) => box.containsKey("credential.$key");

  void set(String key, String value) => box.put("credential.$key", value);
}
