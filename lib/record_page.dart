import 'dart:ffi';
import 'dart:io';
import 'package:ffi/src/utf8.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'native_audio_recording.dart' as nar;

enum RecordingState { Idle, Start }

String _getPath() {
  final openalSoftWrapperPath = Directory.current.absolute.path;
  var path = p.join(openalSoftWrapperPath, 'build\\windows\\native_lib');

  String mode = kDebugMode ? 'Debug' : 'Release';
  path = p.join(path, mode, 'sdl-wrapper.dll');

  print('path: $path');
  return path;
}

class RecordPage extends StatelessWidget {
  RecordingState recordingState = RecordingState.Idle;
  late String appDocPath;
  String audioFileName = "record.wav";
  late String audioFilePath;

  final nativeAudioRecording = nar.NativeAudioRecording(DynamicLibrary.open(_getPath()));

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
              recordingState = RecordingState.Start;
              Pointer<Int8> audioFilePathC = audioFilePath.toNativeUtf8().cast();
              nativeAudioRecording.init(audioFilePathC);
              nativeAudioRecording.start();
              break;
            }
          case RecordingState.Start:
            {
              print("Stop --");
              recordingState = RecordingState.Idle;
              nativeAudioRecording.stop();
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