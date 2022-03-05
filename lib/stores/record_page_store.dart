import 'package:fluent_ui/fluent_ui.dart';
import 'package:mobx/mobx.dart';

import '../model/recording_state.dart';
part 'record_page_store.g.dart';

class RecordPageStore = _RecordPageStore with _$RecordPageStore;

abstract class _RecordPageStore with Store {
  @observable
  RecordingState recordingState = RecordingState.Idle;

  @observable
  ObservableList<Widget> items = <Widget>[].asObservable();

  @action
  setRecordingState(RecordingState value) {
    recordingState = value;
  }

  @action
  addItem(Widget item) {
    items.add(item);
  }

  @action
  removeLast() {
    items.removeLast();
  }
}