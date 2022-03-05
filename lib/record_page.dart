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
import 'package:flutter_trial/record_page_store.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

String _getPath() {
  final openalSoftWrapperPath = Directory.current.absolute.path;
  var path = p.join(openalSoftWrapperPath, 'build\\windows\\native_lib');

  String mode = kDebugMode ? 'Debug' : 'Release';
  path = p.join(path, mode, 'sdl-wrapper.dll');

  print('path: $path');
  return path;
}

class RecordPage extends StatelessWidget {
  final _recordPageStore = RecordPageStore();

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
    List<Widget> items = [ _buildMicButton() ];
    if (_recordPageStore.recordingState == RecordingState.Start) {
      items.add(_buildTimerAnimation());
    }

    return Observer(
        builder: (_) => Column(
        children: items
        )
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
    String audioFilePath = appDocPath + "\\" + audioFileName +
        audioIndex.toString() + audioFileExtension;
    print("Start --> Path : ${audioFilePath}");
    _recordPageStore.setRecordingState(RecordingState.Start);
    Pointer<Int8> audioFilePathC = audioFilePath.toNativeUtf8().cast();
    nativeAudioRecording.init(audioFilePathC);
    nativeAudioRecording.start();
  }

  void _stopRecording() {
    print("Stop --");
    _recordPageStore.setRecordingState( RecordingState.Idle);
    nativeAudioRecording.stop();
    ++audioIndex;
  }

}