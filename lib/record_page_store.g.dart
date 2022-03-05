// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_page_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$RecordPageStore on _RecordPageStore, Store {
  final _$recordingStateAtom = Atom(name: '_RecordPageStore.recordingState');

  @override
  RecordingState get recordingState {
    _$recordingStateAtom.reportRead();
    return super.recordingState;
  }

  @override
  set recordingState(RecordingState value) {
    _$recordingStateAtom.reportWrite(value, super.recordingState, () {
      super.recordingState = value;
    });
  }

  final _$_RecordPageStoreActionController =
      ActionController(name: '_RecordPageStore');

  @override
  dynamic setRecordingState(RecordingState value) {
    final _$actionInfo = _$_RecordPageStoreActionController.startAction(
        name: '_RecordPageStore.setRecordingState');
    try {
      return super.setRecordingState(value);
    } finally {
      _$_RecordPageStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
recordingState: ${recordingState}
    ''';
  }
}
