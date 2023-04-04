import 'dart:convert';

import 'package:ars_cognitio/sugar.dart';
import 'package:googleapis/vision/v1.dart';
import "package:googleapis_auth/auth_io.dart";

class GoogleCloudService extends ArsCognitioStatelessService {
  Future<AuthClient> obtainCredentials() => clientViaServiceAccount(
          ServiceAccountCredentials.fromJson(jsonDecode(
              data().getSettings().googleServiceAccountJson ?? "{}")),
          [
            VisionApi.cloudPlatformScope,
            VisionApi.cloudVisionScope,
          ]);
}
