import 'dart:convert';

import 'package:ars_cognitio/main.dart';
import 'package:ars_cognitio/model/data.dart';
import 'package:ars_cognitio/sugar.dart';
import 'package:fast_log/fast_log.dart';

class DataService extends ArsCognitioService {
  late Data _data;

  Data data() => _data;

  void save() => box.put("data", jsonEncode(_data.toJson()));

  Data _loadData() {
    try {
      return Data.fromJson(jsonDecode(box.get("data", defaultValue: "{}")));
    } catch (e, es) {
      error(e);
      error(es);
    }

    return Data();
  }

  @override
  void onStart() {
    _data = _loadData();
  }

  @override
  void onStop() {}
}
