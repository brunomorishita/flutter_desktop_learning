
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:path/path.dart' as p;
import 'native_audio_recording.dart' as nar;

String _getPath() {
  final openalSoftWrapperPath = Directory.current.absolute.path;
  var path = p.join(openalSoftWrapperPath, 'build\\windows\\native_lib');

  String mode = kDebugMode ? 'Debug' : 'Release';
  path = p.join(path, mode, 'sdl-wrapper.dll');

  print('path: $path');
  return path;
}

class RecordService {
  late String appDocPath;
  final nativeAudioRecording = nar.NativeAudioRecording(DynamicLibrary.open(_getPath()));
  String audioFileName = "record";
  String audioFileExtension = ".raw";
  int audioIndex = 0;

  RecordService() {
    _initializer();
  }

  void _initializer() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    appDocPath = appDocDir.path;
  }

  void start() {
    String audioFilePath = appDocPath + "\\" + audioFileName +
        audioIndex.toString() + audioFileExtension;
    print("Start --> Path : ${audioFilePath}");
    Pointer<Int8> audioFilePathC = audioFilePath.toNativeUtf8().cast();
    nativeAudioRecording.init(audioFilePathC);
    nativeAudioRecording.start();
  }

  void stop() {
    print("Stop --");
    nativeAudioRecording.stop();
    ++audioIndex;
  }
}
