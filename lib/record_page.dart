import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:audio_recorder_nullsafety/audio_recorder_nullsafety.dart';
import 'package:path_provider/path_provider.dart';

enum RecordingState { Idle, Start }

class RecordPage extends StatelessWidget {
  RecordingState recordingState = RecordingState.Idle;
  late String appDocPath;
  String audioFileName = "record.wav";
  late String audioFilePath;

  RecordPage() {
    initializer();
  }

  void initializer() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    appDocPath = appDocDir.path;
    audioFilePath = appDocPath + "\\" + audioFileName;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Center(
      child: _buildMicButton(),
    );
  }

  Widget _buildMicButton({bool sound = true}) {
    var microphoneIcon =
    sound ? FontAwesomeIcons.microphoneAlt : FontAwesomeIcons.microphoneAltSlash;

    return IconButton(
      icon: FaIcon(microphoneIcon),
      onPressed: () async {
        print("Pressed");
        switch (recordingState) {
          case RecordingState.Idle:
            {
              print("Start --> Path : ${audioFilePath}");
              await AudioRecorder.start(
                  path: audioFilePath, audioOutputFormat: AudioOutputFormat.WAV);
              recordingState = RecordingState.Start;
              break;
            }
          case RecordingState.Start:
            {
              Recording recording = await AudioRecorder.stop();
              print("Stop --> Path : ${recording.path},  Format : ${recording.audioOutputFormat},"
                  "Duration : ${recording.duration},  Extension : ${recording.extension},");
              recordingState = RecordingState.Idle;
              break;
            }
        }
      },
    ).card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

}