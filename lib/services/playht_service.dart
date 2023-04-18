import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ars_cognitio/model/playht_voice.dart';
import 'package:ars_cognitio/model/playht_voices.dart';
import 'package:ars_cognitio/sugar.dart';
import 'package:fast_log/fast_log.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:http/http.dart' as http;

class PlayhtService extends ArsCognitioService {
  String user() => data().getSettings().playhtUser ?? "";
  String secret() => data().getSettings().playhtSecret ?? "";

  void setUser(String user) =>
      saveData((d) => d.getSettings().playhtUser = user);

  void setSecret(String secret) =>
      saveData((d) => d.getSettings().playhtSecret = secret);

  Future<void> speakV2(String text) async {
    HttpClient c = HttpClient();
    HttpClientRequest r =
        await c.postUrl(Uri.parse("https://play.ht/api/v2/tts/stream"));
    r.headers.set("content-type", "application/json");
    r.headers.set("authorization", "Bearer ${secret()}");
    r.headers.set("x-user-id", user());
    r.headers.set("accept", "audio/mpeg");
    r.add(utf8.encode(jsonEncode({
      "voice": (data().getSettings().playhtVoice ?? "").toLowerCase(),
      "text": text,
      "sample_rate": 24000,
    })));
    HttpClientResponse res = await r.close();
    Uint8List u = await res.toBytes();
    info("Got back " + u.length.toString() + " Bytes");
    await audioService().playBytes(u);
  }

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
          return;
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

  Future<List<PlayhtVoice>> _getUHDVoices() async {
    HttpClient c = HttpClient();
    HttpClientRequest r =
        await c.getUrl(Uri.parse("https://play.ht/api/v2/voices"));
    r.headers.set("content-type", "application/json");
    r.headers.set("authorization", "Bearer ${secret()}");
    r.headers.set("x-user-id", user());
    HttpClientResponse res = await r.close();
    Uint8List u = await res.toBytes();
    info("Got back " + u.length.toString() + " Bytes");
    return (jsonDecode(utf8.decode(u)) as List<dynamic>)
        .map((e) => PlayhtVoice.fromJson(e as Map<String, dynamic>))
        .toList();
  }

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
