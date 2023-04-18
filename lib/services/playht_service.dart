import 'dart:convert';

import 'package:ars_cognitio/model/playht_voice.dart';
import 'package:ars_cognitio/model/playht_voices.dart';
import 'package:ars_cognitio/sugar.dart';
import 'package:fast_log/fast_log.dart';
import 'package:http/http.dart' as http;

class PlayhtService extends ArsCognitioService {
  String user() => data().getSettings().playhtUser ?? "";
  String secret() => data().getSettings().playhtSecret ?? "";

  void setUser(String user) =>
      saveData((d) => d.getSettings().playhtUser = user);

  void setSecret(String secret) =>
      saveData((d) => d.getSettings().playhtSecret = secret);

  Future<void> speak(String text) => http
          .post(Uri.parse("https://play.ht/api/v1/convert"),
              headers: {
                "Authorization": secret(),
                "X-User-ID": user(),
                "Content-Type": "application/json"
              },
              body: jsonEncode({
                "voice": data().getSettings().playhtVoice ?? "",
                "content": [text],
              }))
          .then((value) {
        info("Got response: ${value.body}");
        return value;
      }).then((value) => waitAndPlay(jsonDecode(value.body)));

  Future<void> waitAndPlay(Map<String, dynamic> json) async {
    if (json["status"] == "SUCCESS" || json["audioUrl"] != null) {
      while (true) {
        await Future.delayed(const Duration(seconds: 1), () {});
        try {
          await audioService()
              .playMedia((json["audioUrl"] as List<dynamic>)[0].toString());
          success("Played!");
          break;
        } catch (e, es) {
          warn(e);
        }
      }
    } else {
      await Future.delayed(const Duration(seconds: 1));
      String trs = json["transcriptionId"];
      http.get(
          Uri.parse(
              "https://play.ht/api/v1/articleStatus?transcriptionId=$trs"),
          headers: {
            "Authorization": secret(),
            "X-User-ID": user(),
            "Content-Type": "application/json"
          }).then((value) {
        info("Got (waiting) response: ${value.body}");
        return value;
      }).then((value) => waitAndPlay(jsonDecode(value.body)));
    }
  }

  Future<List<PlayhtVoice>> getUHDVoices() => _uhdVoices;

  Future<List<PlayhtVoice>> _getUHDVoices() =>
      http.get(Uri.parse("https://play.ht/api/v1/getVoices?ultra=true"),
          headers: {
            "Authorization": secret(),
            "X-User-ID": user(),
            "Content-Type": "application/json"
          }).then((value) {
        if (value.statusCode == 200) {
          return PlayhtVoices.fromJson(jsonDecode(value.body)).voices ?? [];
        } else {
          error("Failed to get UHD Voices: ${value.statusCode}");
        }
        return [];
      });

  late Future<List<PlayhtVoice>> _uhdVoices;

  @override
  void onStart() {
    _uhdVoices = _getUHDVoices();
  }

  @override
  void onStop() {
    // TODO: implement onStop
  }
}
