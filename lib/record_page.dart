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
  String audioFileName = "record";
  String audioFileExtension = ".raw";
  int audioIndex = 0;

  final nativeAudioRecording = nar.NativeAudioRecording(DynamicLibrary.open(_getPath()));

  RecordPage() {
    initializer();
  }

  void initializer() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    appDocPath = appDocDir.path;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMicButton(),
        _buildTimerAnimation(),
      ],
    );
  }

  Widget _buildTimerAnimation() {
    return TweenAnimationBuilder<Duration>(
        duration: const Duration(seconds: 400),
        tween: Tween(begin: const Duration(seconds: 0), end:const Duration(seconds: 400)),
        onEnd: () {
          print('Timer ended');
        },
        builder: (BuildContext context, Duration value, Widget? child) {
          final minutes = value.inMinutes;
          final seconds = value.inSeconds % 60;
          return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text('$minutes:$seconds',
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
      icon: FaIcon(microphoneIcon),
      onPressed: () async {
        print("Pressed");
        switch (recordingState) {
          case RecordingState.Idle:
            {
              String audioFilePath = appDocPath + "\\" + audioFileName +
                  audioIndex.toString() + audioFileExtension;
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
              ++audioIndex;
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