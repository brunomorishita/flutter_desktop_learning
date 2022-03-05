import 'dart:io';
import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_trial/model/sound_service.dart';

class AudioFilePage extends StatelessWidget {
  final _controller = ScrollController();
  final SoundService _soundService = SoundService();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _controller,
      child: ListView.builder(
          itemCount: _soundService.savedAudioFiles.length,
          itemBuilder: (context, index) {
            final title = _soundService.savedAudioFiles.elementAt(index);
            final stat = FileStat.statSync(title);
            final details = stat.changed.toString();
            String trailing = stat.size.toString();

            int exponent;
            String unit;
            if (stat.size / pow(10, 9) > 1) {
              exponent = 9;
              unit = 'G';
            } else if (stat.size / pow(10, 6) > 1) {
              exponent = 6;
              unit = 'M';
            } else if (stat.size / pow(10, 3) > 1) {
              exponent = 3;
              unit = 'K';
            } else {
              exponent = 0;
              unit = '';
            }

            trailing = (stat.size / pow(10, exponent)).toStringAsFixed(2) + unit;

            return ListTile(
              leading: Button(
                child: Icon(FluentIcons.play),
                onPressed: () {
                  _soundService.playStart(title);
                },
              ),
              title: Text(title),
              subtitle: Text(details!),
              trailing: Text(trailing),
            );
          }
      ),
    );
  }

}