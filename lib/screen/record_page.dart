import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_trial/screen/widget/blinking_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:flutter_trial/stores/record_page_store.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../model/recording_state.dart';
import '../utils.dart' as utils;

class RecordPage extends StatelessWidget {
  final _recordPageStore = RecordPageStore();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Widget getItems(_) {
      List<Widget> items = <Widget>[
        _buildRecSignal(),
        _buildMicButton()
      ];

      if (_recordPageStore.recordingState == RecordingState.Start) {
        items.add(_buildTimerAnimation());
      }

      return Column(
          children: items
      )
          .padding(vertical: 20)
          .card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          )
      );
    }

    return Observer(
        builder: getItems
    );
  }

  Widget _buildRecSignal() {
    return <Widget>[
      _buildRedLightAnimation(_recordPageStore.blink),
      SizedBox(width: 5, height: 5),
      Text("REC",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        )
      )
    ].toRow(mainAxisAlignment: MainAxisAlignment.center)
        .padding(vertical: 20);
  }

  Widget _buildRedLightAnimation(bool blink) {
    Widget redCircle = Styled.widget()
        .backgroundColor(Colors.red)
        .constrained(width: 15, height: 15)
        .clipOval();

    if (!blink)
      return redCircle;

    return BlinkWidget(
        children: <Widget>[
          redCircle,
          Styled.widget()
              .backgroundColor(Colors.transparent)
              .constrained(width: 15, height: 15)
              .clipOval(),
    ]);
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
              child: Text(utils.printDuration(value),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 30)));
        });
  }

  Widget _buildMicButton({bool sound = true}) {
    void handleTap() {
      print("handleTap --");
        switch (_recordPageStore.recordingState) {
            case RecordingState.Idle: _startRecording(); break;
            case RecordingState.Start: _stopRecording(); break;
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
    _recordPageStore.setBlink(true);
    _recordPageStore.setRecordingState(RecordingState.Start);
  }

  void _stopRecording() {
    _recordPageStore.setBlink(false);
    _recordPageStore.setRecordingState( RecordingState.Stop);
    _recordPageStore.setRecordingState(RecordingState.Idle);
  }
}