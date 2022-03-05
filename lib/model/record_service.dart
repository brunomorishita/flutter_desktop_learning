
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
  late String _audioFilePath;

  List<String> _savedAudioFiles = <String>[];

  final _nativeAudioRecording = nar.NativeAudioRecording(DynamicLibrary.open(_getPath()));
  String _audioFileName = "record";
  String _audioFileExtension = ".wav";
  int _audioIndex = 0;

  static final RecordService _instance = RecordService.internal();

  RecordService.internal() {
    _initializer();
  }

  factory RecordService() {
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

  void start() {
    _audioFilePath = appDocPath + "\\" + _audioFileName + "-" +
        _audioIndex.toString() + _audioFileExtension;
    print("Start --> Path : ${_audioFilePath}");
    Pointer<Int8> audioFilePathC = _audioFilePath.toNativeUtf8().cast();
    _nativeAudioRecording.init(audioFilePathC);
    _nativeAudioRecording.start();
  }

  void stop() {
    print("Stop --");
    _nativeAudioRecording.stop();
    ++_audioIndex;
    _savedAudioFiles.add(_audioFilePath);
  }
}
