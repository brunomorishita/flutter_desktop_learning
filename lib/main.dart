import 'package:fluent_ui/fluent_ui.dart';
import 'package:system_theme/system_theme.dart';
import 'home_page.dart';

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


