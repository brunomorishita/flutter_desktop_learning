import 'dart:io';
import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_trial/model/sound_service.dart';
import 'package:styled_widget/styled_widget.dart';

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
        itemBuilder: _buildItem
    ).card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          )
      )
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    String completePath = _soundService.savedAudioFiles.elementAt(index);
    final title = (completePath.split('\\').last);
    final stat = FileStat.statSync(completePath);
    final details = stat.changed.toString();
    String trailing = _getSizeFormatted(completePath);

    final Widget titleWidget = Text(title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    );

    return ListTile(
      leading: Button(
        child: Icon(FluentIcons.play),
        onPressed: () {
          _soundService.playStart(completePath);
          },
      ),
      title: titleWidget,
      subtitle: Text(details!),
      trailing: Text(trailing),
    );
  }

  String _getSizeFormatted(String value) {
    final stat = FileStat.statSync(value);
    String ret = stat.size.toString();

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

    ret = (stat.size / pow(10, exponent)).toStringAsFixed(2) + unit;
    return ret;
  }
}