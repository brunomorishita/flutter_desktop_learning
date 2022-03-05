import 'package:fluent_ui/fluent_ui.dart';
import 'package:mobx/mobx.dart';

import '../model/sound_service.dart';
import '../model/recording_state.dart';
part 'record_page_store.g.dart';

class RecordPageStore = _RecordPageStore with _$RecordPageStore;

abstract class _RecordPageStore with Store {
  final SoundService _soundService = SoundService();

  @observable
  RecordingState recordingState = RecordingState.Idle;

  @observable
  ObservableList<Widget> items = <Widget>[].asObservable();

  @observable
  Color recordLightColor = Colors.red;

  @action
  setRecordingState(RecordingState value) {
    recordingState = value;

    switch(recordingState) {
      case RecordingState.Idle: break;
      case RecordingState.Start : _soundService.recordStart(); break;
      case RecordingState.Stop : _soundService.recordStop(); break;
    }
  }

  @action
  addItem(Widget item) {
    items.add(item);
  }

  @action
  removeLast() {
    items.removeLast();
  }

  @action
  setRecordLightColor(Color value) {
    recordLightColor = value;
  }
}