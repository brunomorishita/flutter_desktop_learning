import 'package:mobx/mobx.dart';
part 'record_page_store.g.dart';

enum RecordingState { Idle, Start }

class RecordPageStore = _RecordPageStore with _$RecordPageStore;

abstract class _RecordPageStore with Store {
  @observable
  RecordingState recordingState = RecordingState.Idle;

  @action
  setRecordingState(RecordingState value) {
    recordingState = value;
  }
}