import 'dart:convert';

import 'package:ars_cognitio/model/diffusion_model.dart';
import 'package:ars_cognitio/sugar.dart';
import 'package:fast_log/fast_log.dart';
import 'package:http/http.dart' as http;
import 'package:snackbar/snackbar.dart';

class StableDiffusionService extends ArsCognitioService {
  DiffusionModel defaultModel = DiffusionModel()
    ..id = "stablediffusion"
    ..name = "Stable Diffusion"
    ..description = "Stable Diffusion's own model";
  late Future<List<DiffusionModel>> _models;

  String getKey() => data().getSettings().stableDiffusionApiKey ?? "";

  void setKey(String key) =>
      saveData((d) => d.getSettings().stableDiffusionApiKey = key);

  Future<List<String>> _continueFetching(String fetchUrl) async {
    await Future.delayed(const Duration(seconds: 3), () {});
    var r = await http.post(Uri.parse(fetchUrl), body: {"key": getKey()});

    info("Response: ${r.body}");
    Map<String, dynamic> j = jsonDecode(r.body);
    if (j["status"] == "success") {
      info("Finally got the image!");
      return (j["output"] as List<dynamic>)
          .map((e) => e.toString().replaceAll("\\", "/"))
          .toList();
    } else {
      info("Still waiting for the image...");
      return _continueFetching(fetchUrl);
    }
  }

  Future<List<String>> text2Image({
    required DiffusionModel model,
    String? prompt,
    String? negativePrompt,
    int samples = 1,
    double promptStrength = 0.5,
    int width = 512,
    int height = 512,
    int inferenceSteps = 1, // 1 - 50
    double guidanceScale = 1, // 1 - 20
    int? seed,
    bool enhancePrompt = true,
    bool safetyChecker = true,
  }) =>
      model.id == defaultModel.id
          ? _text2ImageStableDiffusion(
              prompt: prompt,
              negativePrompt: negativePrompt,
              samples: samples,
              promptStrength: promptStrength,
              width: width,
              height: height,
              inferenceSteps: inferenceSteps,
              guidanceScale: guidanceScale,
              seed: seed,
              enhancePrompt: enhancePrompt,
              safetyChecker: safetyChecker,
            )
          : _text2ImageCommunity(
              prompt: prompt,
              model: model.id,
              negativePrompt: negativePrompt,
              samples: samples,
              promptStrength: promptStrength,
              width: width,
              height: height,
              inferenceSteps: inferenceSteps,
              guidanceScale: guidanceScale,
              seed: seed,
              enhancePrompt: enhancePrompt,
              safetyChecker: safetyChecker,
            );

  Future<List<String>> _text2ImageStableDiffusion({
    String? prompt,
    String? negativePrompt,
    int samples = 1,
    double promptStrength = 0.5,
    int width = 512,
    int height = 512,
    int inferenceSteps = 1, // 1 - 50
    double guidanceScale = 1, // 1 - 20
    int? seed,
    bool enhancePrompt = true,
    bool safetyChecker = true,
  }) =>
      http.post(Uri.parse("https://stablediffusionapi.com/api/v3/text2img"),
          body: {
            "key": getKey(),
            "samples": samples.toString(),
            "prompt": prompt ?? "",
            "negative_prompt": negativePrompt ?? "",
            if (seed != null) "seed": seed,
            "num_inference_steps": inferenceSteps.toString(),
            "guidance_scale": guidanceScale.toString(),
            "enhance_prompt": enhancePrompt ? "yes" : "no",
            "safety_checker": safetyChecker ? "yes" : "no",
            "prompt_strength": promptStrength.toString(),
            "width": "$width",
            "height": "$height",
          }).then((value) {
        info("Response: ${value.body}");
        Map<String, dynamic> j = jsonDecode(value.body);
        if (j["status"] == "error") {
          error(j["message"]);
          snack(j["message"]);
          return [];
        }

        if (j["status"] == "processing" && j["fetch_result"] != null) {
          return _continueFetching(j["fetch_result"]);
        }

        try {
          return (j["output"] as List<dynamic>)
              .map((e) => e.toString())
              .toList();
        } catch (e, es) {
          error(e);
          error(es);
          warn(value.body);
        }

        return [];
      });

  Future<bool> serverDeleteImage(String image) async {
    var r = await http.post(
        Uri.parse("https://stablediffusionapi.com/api/v3/delete_image"),
        body: {
          "key": getKey(),
          "image": image.split("/").last,
        });
    info("Response: ${r.body}");
    return r.statusCode == 200;
  }

  Future<List<String>> _text2ImageCommunity({
    String? prompt,
    String? model,
    String? negativePrompt,
    int samples = 1,
    double promptStrength = 0.5,
    int width = 512,
    int height = 512,
    int inferenceSteps = 1, // 1 - 50
    double guidanceScale = 1, // 1 - 20
    int? seed,
    bool enhancePrompt = true,
    bool safetyChecker = true,
  }) =>
      http.post(Uri.parse("https://stablediffusionapi.com/api/v4/dreambooth"),
          body: {
            "key": getKey(),
            "samples": samples.toString(),
            "prompt": prompt ?? "",
            "model_id": model ?? "",
            "negative_prompt": negativePrompt ?? "",
            if (seed != null) "seed": seed,
            "num_inference_steps": inferenceSteps.toString(),
            "guidance_scale": guidanceScale.toString(),
            "enhance_prompt": enhancePrompt ? "yes" : "no",
            "safety_checker": safetyChecker ? "yes" : "no",
            "prompt_strength": promptStrength.toString(),
            "width": "$width",
            "height": "$height",
          }).then((value) {
        info("Response: ${value.body}");
        Map<String, dynamic> j = jsonDecode(value.body);
        if (j["status"] == "processing" && j["fetch_result"] != null) {
          return _continueFetching(j["fetch_result"]);
        }

        try {
          return (j["output"] as List<dynamic>)
              .map((e) => e.toString())
              .toList();
        } catch (e, es) {
          error(e);
          error(es);
          warn(value.body);
        }

        return [];
      });

  Future<List<DiffusionModel>> listModels() => _models;

  Future<List<DiffusionModel>> _listCommunityModels() => http
      .post(
          Uri.parse(
              "https://stablediffusionapi.com/api/v4/dreambooth/model_list"),
          body: {"key": getKey()})
      .then((value) => (jsonDecode(value.body) as List<dynamic>)
          .map((e) => DiffusionModel.fromJson(e))
          .toList())
      .then((value) {
        value.insert(0, defaultModel);
        return value;
      });

  @override
  void onStart() {
    _models = _listCommunityModels();
  }

  @override
  void onStop() {}
}
