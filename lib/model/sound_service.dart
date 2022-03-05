
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

class SoundService {
  late String appDocPath;
  late String _audioFilePath;

  List<String> _savedAudioFiles = <String>[];

  final _nativeAudioRecording = nar.NativeAudioRecording(DynamicLibrary.open(_getPath()));
  String _audioFileName = "record";
  String _audioFileExtension = ".wav";
  int _audioIndex = 0;

  static final SoundService _instance = SoundService.internal();

  SoundService.internal() {
    _initializer();
  }

  factory SoundService() {
    return _instance;
  }

  void _initializer() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    appDocPath = appDocDir.path;
    _audioFilePath = appDocPath + "\\" + _audioFileName + "-" +
        _audioIndex.toString() + _audioFileExtension;
  }

  List<String> get savedAudioFiles {
    return _savedAudioFiles;
  }

  void recordStart() {
    _audioFilePath = appDocPath + "\\" + _audioFileName + "-" +
        _audioIndex.toString() + _audioFileExtension;
    print("Start --> Path : ${_audioFilePath}");
    Pointer<Int8> audioFilePathC = _audioFilePath.toNativeUtf8().cast();
    _nativeAudioRecording.record_init(audioFilePathC);
    _nativeAudioRecording.record_start();
  }

  void recordStop() {
    print("Stop --");
    _nativeAudioRecording.record_stop();
    ++_audioIndex;
    _savedAudioFiles.add(_audioFilePath);
  }

  void playStart(String audioFile) {
    print("Play Start --> ${audioFile}");
    Pointer<Int8> audioFilePathC = audioFile.toNativeUtf8().cast();
    _nativeAudioRecording.play_init(audioFilePathC);
    _nativeAudioRecording.play_start();
  }

  void playStop() {
    print("Play Stop --");
    _nativeAudioRecording.play_stop();
  }
}
