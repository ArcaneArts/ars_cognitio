import 'dart:async';

import 'package:ars_cognitio/sugar.dart';
import 'package:fast_log/fast_log.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioService extends ArsCognitioStatelessService {
  bool playing = false;
  VoidCallback stopper = () {};
  StreamController<bool> playingStream = StreamController<bool>.broadcast();

  Future<void> playMedia(String url) async {
    info("Playing $url");
    playing = true;
    playingStream.add(true);
    AudioPlayer p = AudioPlayer();
    stopper = () => p.pause().then((value) => p.stop());
    await p.setUrl(url);
    await p.play();
    await p.stop();
    playing = false;
    playingStream.add(false);
    stopper = () {};
  }
}
