import 'package:ars_cognitio/ui/cupertino_app.dart';
import 'package:ars_cognitio/ui/fluent_app.dart';
import 'package:ars_cognitio/ui/macos_app.dart';
import 'package:ars_cognitio/ui/material_app.dart';
import 'package:flutter/widgets.dart';
import 'package:universal_io/io.dart';

enum ChameleonPlatform {
  material,
  macos,
  cupertino,
  fluent;

  Widget get app {
    switch (this) {
      case ChameleonPlatform.material:
        return const ArsCognitioMaterialApp();
      case ChameleonPlatform.macos:
        return const ArsCognitioMacosApp();
      case ChameleonPlatform.cupertino:
        return const ArsCognitioCupertinoApp();
      case ChameleonPlatform.fluent:
        return const ArsCognitioFluentApp();
    }
  }

  static ChameleonPlatform get() {
    if (true) {
      return ChameleonPlatform.material;
    }

    if (Platform.isIOS) {
      return ChameleonPlatform.cupertino;
    } else if (Platform.isWindows) {
      return ChameleonPlatform.fluent;
    } else if (Platform.isMacOS) {
      return ChameleonPlatform.macos;
    }
    return ChameleonPlatform.material;
  }
}
