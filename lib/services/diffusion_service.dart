import 'dart:async';
import 'dart:convert';

import 'package:ars_cognitio/model/diffusion_model.dart';
import 'package:ars_cognitio/model/generated_image.dart';
import 'package:ars_cognitio/sugar.dart';
import 'package:dialoger/dialoger.dart';
import 'package:fast_log/fast_log.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:memcached/memcached.dart';
import 'package:snackbar/snackbar.dart';

List<String> thoseModels = [
  "f22-diffusion",
  "grapefruit-nsfw-anim",
  "renwu",
  "urpm"
];

class SystemLoad {
  int queued;
  double queueTime;

  SystemLoad(this.queued, this.queueTime);
}

class DiffusionService extends ArsCognitioService {
  StreamController<SystemLoad> systemLoadStream = StreamController.broadcast();
  DiffusionModel defaultModel = DiffusionModel()
    ..id = "stablediffusion"
    ..name = "Stable Diffusion"
    ..description = "Stable Diffusion's own model";
  late Future<List<DiffusionModel>> _models;

  Stream<SystemLoad> streamSystemLoad() {
    Stream<SystemLoad> s = systemLoadStream.stream;
    systemLoad();

    return s;
  }

  String getKey() => data().getSettings().stableDiffusionApiKey ?? "";

  void setKey(String key) =>
      saveData((d) => d.getSettings().stableDiffusionApiKey = key);

  Future<SystemLoad> systemLoad() => getCached(
              id: "systemload",
              getter: () => http.post(
                      Uri.parse(
                          "https://stablediffusionapi.com/api/v3/system_load"),
                      body: {"key": getKey()}).then((value) {
                    info(value.body);
                    Map<String, dynamic> j = jsonDecode(value.body);
                    return SystemLoad(
                        j["queue_num"], (j["queue_time"] as num).toDouble());
                  }),
              duration: const Duration(seconds: 5))
          .then((value) {
        systemLoadStream.add(value);
        return value;
      });

  Future<List<String>> _continueFetching(String fetchUrl) async {
    await Future.delayed(const Duration(seconds: 5), () {});
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
      systemLoad();
      return _continueFetching(fetchUrl);
    }
  }

  Future<GeneratedImage> text2Image({
    required DiffusionModel model,
    String? prompt,
    String? negativePrompt,
    double promptStrength = 0.5,
    int width = 512,
    int height = 512,
    int inferenceSteps = 1, // 1 - 50
    double guidanceScale = 1, // 1 - 20
    int? seed,
    bool enhancePrompt = true,
    bool safetyChecker = true,
  }) =>
      (model.id == defaultModel.id
              ? _text2ImageStableDiffusion(
                  prompt: prompt,
                  negativePrompt: negativePrompt,
                  samples: 1,
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
                  samples: 1,
                  promptStrength: promptStrength,
                  width: width,
                  height: height,
                  inferenceSteps: inferenceSteps,
                  guidanceScale: guidanceScale,
                  seed: seed,
                  enhancePrompt: enhancePrompt,
                  safetyChecker: safetyChecker,
                ))
          .then((value) => GeneratedImage()
            ..image = value[0]
            ..inferenceSteps = inferenceSteps
            ..promptStrength = promptStrength
            ..prompt = prompt
            ..width = width
            ..height = height
            ..enhancePrompt = enhancePrompt
            ..safetyChecker = safetyChecker
            ..guidanceScale = guidanceScale
            ..negativePrompt = negativePrompt
            ..model = model.id
            ..seed = seed);

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

  void deleteDialog(BuildContext context, String image) => dialogConfirm(
      context: context,
      title: "Delete Image?",
      description:
          "An attempt will be made to delete it off of the Stable Diffusion API's history, if it succeeds, we will also delete it here, otherwise it wont be deleted here.\n\nNote: Thumbnails & API History is still stored on the StableDiffusion API Servers & Dashboard!",
      confirmButtonText: "Server Delete",
      onConfirm: (context) {
        stableDiffusionService().serverDeleteImage(image).then((value) {
          if (value) {
            snack("Successful Server Delete!");
            saveData((d) =>
                d.getGenerated().removeWhere((element) => element == image));
            Future.delayed(
                Duration(milliseconds: 50), () => Navigator.pop(context));
          } else {
            snack("Failed Server Delete!");
          }
        });
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

  Future<String> superResolution(String url, double scale,
      {bool enhanceFace = false}) async {
    var r = await http.post(
        Uri.parse("https://stablediffusionapi.com/api/v3/super_resolution"),
        body: {
          "key": getKey(),
          "scale": scale.toString(),
          "url": url,
          "face_enhance": enhanceFace.toString()
        });
    info("Response: ${r.body}");
    await Future.delayed(const Duration(milliseconds: 2000));
    return jsonDecode(r.body)["output"].replaceAll("\\", "/");
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

  Future<GeneratedImage> image2Image({
    required DiffusionModel model,
    String? prompt,
    String? negativePrompt,
    double promptStrength = 0.5,
    int width = 512,
    required String init,
    int height = 512,
    int inferenceSteps = 1, // 1 - 50
    double guidanceScale = 1, // 1 - 20
    int? seed,
    bool enhancePrompt = true,
    bool safetyChecker = true,
  }) =>
      (model.id == defaultModel.id
              ? _image2ImageStableDiffusion(
                  prompt: prompt,
                  negativePrompt: negativePrompt,
                  samples: 1,
                  promptStrength: promptStrength,
                  init: init,
                  width: width,
                  height: height,
                  inferenceSteps: inferenceSteps,
                  guidanceScale: guidanceScale,
                  seed: seed,
                  enhancePrompt: enhancePrompt,
                  safetyChecker: safetyChecker,
                )
              : _image2ImageCommunity(
                  prompt: prompt,
                  model: model.id,
                  negativePrompt: negativePrompt,
                  samples: 1,
                  init: init,
                  promptStrength: promptStrength,
                  width: width,
                  height: height,
                  inferenceSteps: inferenceSteps,
                  guidanceScale: guidanceScale,
                  seed: seed,
                  enhancePrompt: enhancePrompt,
                  safetyChecker: safetyChecker,
                ))
          .then((value) => GeneratedImage()
            ..image = value[0]
            ..inferenceSteps = inferenceSteps
            ..promptStrength = promptStrength
            ..prompt = prompt
            ..width = width
            ..height = height
            ..enhancePrompt = enhancePrompt
            ..safetyChecker = safetyChecker
            ..guidanceScale = guidanceScale
            ..negativePrompt = negativePrompt
            ..model = model.id
            ..seed = seed
            ..promptImage = init);

  Future<List<String>> _image2ImageStableDiffusion({
    String? prompt,
    String? negativePrompt,
    int samples = 1,
    double promptStrength = 0.5,
    int width = 512,
    int height = 512,
    int inferenceSteps = 1, // 1 - 50
    double guidanceScale = 1, // 1 - 20
    int? seed,
    required String init,
    bool enhancePrompt = true,
    bool safetyChecker = true,
  }) =>
      http.post(Uri.parse("https://stablediffusionapi.com/api/v3/img2img"),
          body: {
            "key": getKey(),
            "samples": samples.toString(),
            "prompt": prompt ?? "",
            "negative_prompt": negativePrompt ?? "",
            "init_image": init,
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

  Future<List<String>> _image2ImageCommunity({
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
    required String init,
    bool enhancePrompt = true,
    bool safetyChecker = true,
  }) =>
      http.post(
          Uri.parse("https://stablediffusionapi.com/api/v3/dreambooth/img2img"),
          body: {
            "key": getKey(),
            "samples": samples.toString(),
            "prompt": prompt ?? "",
            "model_id": model ?? "",
            "init_image": init,
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
