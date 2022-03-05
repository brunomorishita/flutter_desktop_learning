import 'package:fluent_ui/fluent_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:styled_widget/styled_widget.dart';
import '../model/recording_state.dart';

import 'package:flutter_trial/stores/record_page_store.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class RecordPage extends StatelessWidget {
  final _recordPageStore = RecordPageStore();

  RecordPage() {
    initializer();
  }

  void initializer() async {
    _recordPageStore.addItem(_buildMicButton());
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Observer(
        builder: (_) => Column(
        children: _recordPageStore.items
        )
    );
  }

  Widget _buildTimerAnimation() {
    return TweenAnimationBuilder<Duration>(
        duration: const Duration(days: 3),
        tween: Tween(begin: const Duration(seconds: 0), end:const Duration(days: 3)),
        onEnd: () {
          print('Timer ended');
        },
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
    var microphoneIcon =
    sound ? FontAwesomeIcons.microphoneAlt : FontAwesomeIcons.microphoneAltSlash;

    return IconButton(
      icon: FaIcon(microphoneIcon, size: 40),
      onPressed: () async {
        print("Pressed");
        switch (_recordPageStore.recordingState) {
          case RecordingState.Idle: _startRecording(); break;
          case RecordingState.Start: _stopRecording(); break;
        }
      },
    ).card(
      elevation: 50,
      color: Colors.transparent,
      shape: const CircleBorder(side: BorderSide.none ),
    );
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