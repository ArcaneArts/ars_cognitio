import 'package:ars_cognitio/sugar.dart';
import 'package:flutter/material.dart';

class PlayStreamer extends StatelessWidget {
  Widget playing;
  Widget notPlaying;

  PlayStreamer({Key? key, required this.playing, required this.notPlaying})
      : super(key: key);

  @override
  Widget build(BuildContext context) => StreamBuilder<bool>(
      stream: audioService().playingStream.stream,
      builder: (context, snap) => (snap.data ?? false) ? playing : notPlaying);
}
