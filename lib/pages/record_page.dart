import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:styled_widget/styled_widget.dart';
import '../model/recording_state.dart';

import 'package:flutter_trial/stores/record_page_store.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class RecordPage extends StatelessWidget {
  final _recordPageStore = RecordPageStore();

  late Timer _timer;
  final _animationDuration = Duration(seconds: 1);

  RecordPage() {
    initializer();
  }

  void initializer() async {
    _recordPageStore.addItem(_buildRecSignal());
    _recordPageStore.addItem(_buildMicButton());
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Observer(
        builder: (_) => Column(
        children: _recordPageStore.items
        )
            .padding(vertical: 20)
            .card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            )
        )
    );
  }

  Widget _buildRecSignal() {
    return <Widget>[
      _buildRedLightAnimation(),
      Text("REC",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        )
      )
    ].toRow(mainAxisAlignment: MainAxisAlignment.center)
        .padding(vertical: 20);
  }

  Widget _buildRedLightAnimation() {
    return Styled.widget()
        .backgroundColor(_recordPageStore.recordLightColor)
        .constrained(width: 15, height: 15)
        .clipOval();
  }

  Widget _buildTimerAnimation() {
    return TweenAnimationBuilder<Duration>(
        duration: const Duration(days: 3),
        tween: Tween(
            begin: const Duration(seconds: 0),
            end: const Duration(days: 3)
        ),
        builder: (BuildContext context, Duration value, Widget? child) {
          return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(_printDuration(value),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 30)));
        });
  }

  Widget _buildMicButton({bool sound = true}) {
    _timer = Timer.periodic(_animationDuration, (timer) {
      var _color = _recordPageStore.recordLightColor;
      _color = (_color == Colors.red) ? Colors.white : Colors.red;
      _recordPageStore.setRecordLightColor(_color);
    });

    void handleTap() {
      print("handleTap --");
        switch (_recordPageStore.recordingState) {
            case RecordingState.Idle: _startRecording(); break;
            case RecordingState.Start: {
              _timer.cancel();
              _stopRecording();
              break;
            }
        }
    }

    return FaIcon(FluentIcons.microphone, size: 40, color: Colors.white,)
        .alignment(Alignment.center)
        .backgroundColor(Color(0xff80D8FF))
        .constrained(width: 100, height: 100)
        .clipOval()
        .gestures(onTap: handleTap);
  }

  void _startRecording() {
    _recordPageStore.setRecordingState(RecordingState.Start);
    _recordPageStore.addItem(_buildTimerAnimation());
  }

  void _stopRecording() {
    _recordPageStore.setRecordingState( RecordingState.Stop);
    _recordPageStore.removeLast();
    _recordPageStore.setRecordingState(RecordingState.Idle);
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String ret = "";

    int hour = duration.inHours.remainder(24);
    int minute = duration.inMinutes.remainder(60);
    int second = duration.inSeconds.remainder(60);
    int milissecond = duration.inMilliseconds.remainder(1000);

    String twoDigitHours = twoDigits(hour);
    String twoDigitMinutes = twoDigits(minute);
    String twoDigitSeconds = twoDigits(second);
    String twoDigitMilliseconds = twoDigits(milissecond);

    if (hour > 0) {
      ret += twoDigitHours + ":";
    }

    if (minute > 0) {
      ret += twoDigitMinutes + ":";
    }

    if (second > 0) {
      ret += twoDigitSeconds + ".";
    }

    if (milissecond > 0) {
      ret += twoDigitMilliseconds;
    }

    return ret;
  }
}