import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_trial/pages/record_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'audio_file_page.dart';
import '../stores/home_page_store.dart';

class HomePage extends StatelessWidget {
  final HomePageStore _homePageStore = HomePageStore();

  @override
  Widget build(BuildContext context) {
    return Observer(
        builder: (_) => NavigationView(
              appBar: NavigationAppBar(
                title: Text(AppLocalizations.of(context)!.appBarTitle),
                automaticallyImplyLeading: false,
              ),
              pane: NavigationPane(
                selected: _homePageStore.index,
                onChanged: (i) => _homePageStore.setIndex(i),
                displayMode: PaneDisplayMode.auto,
                items: _getPanelItems(context),
              ),
              content: NavigationBody(
                index: _homePageStore.index,
                children: [RecordPage(), AudioFilePage()],
              ),
            ));
  }

  List<NavigationPaneItem> _getPanelItems(BuildContext context) {
    return <NavigationPaneItem>[
      PaneItem(
        icon: FaIcon(FontAwesomeIcons.microphone),
        title: Text(AppLocalizations.of(context)!.panelItemRecord),
      ),
      PaneItem(
        icon: FaIcon(FontAwesomeIcons.folder),
        title: Text(AppLocalizations.of(context)!.panelItemFiles),
      ),
    ];
  }
}
