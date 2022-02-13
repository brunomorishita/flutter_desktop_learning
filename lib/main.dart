import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_trial/home_page_store.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:system_theme/system_theme.dart';
import 'record_page.dart';
import 'audio_file_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FluentApp(
        title: 'Voice Recording',
        theme: ThemeData(accentColor: SystemTheme.accentInstance.accent.toAccentColor()),
        home: HomePage());
  }
}

class HomePage extends StatelessWidget {
  final HomePageStore _homePageStore = HomePageStore();

  @override
  Widget build(BuildContext context) {
    return Observer(
        builder: (_) => NavigationView(
              appBar: NavigationAppBar(
                title: const Text("Voice Recording 2"),
                automaticallyImplyLeading: false,
              ),
              pane: NavigationPane(
                selected: _homePageStore.index,
                onChanged: (i) => _homePageStore.setIndex(i),
                displayMode: PaneDisplayMode.auto,
                items: _getPanelItems(),
              ),
              content: NavigationBody(
                index: _homePageStore.index,
                children: [RecordPage(), AudioFilePage()],
              ),
            ));
  }

  List<NavigationPaneItem> _getPanelItems() {
    return <NavigationPaneItem>[
      PaneItem(
        icon: FaIcon(FontAwesomeIcons.home),
        title: const Text('Home'),
      ),
      PaneItem(
        icon: FaIcon(FontAwesomeIcons.solidFileAudio),
        title: const Text('Files'),
      ),
    ];
  }
}
