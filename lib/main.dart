import 'package:fluent_ui/fluent_ui.dart';
import 'package:system_theme/system_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'pages/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FluentApp(
        onGenerateTitle: (context) {
          return AppLocalizations.of(context)!.appTitle;
        },
        localizationsDelegates: [
          AppLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          accentColor: SystemTheme.accentInstance.accent.toAccentColor(),
          typography: const Typography(
            caption: TextStyle(
              fontFamily: 'Segoe UI',
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        home: HomePage());
  }
}


