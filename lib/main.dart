import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/features/family/presentation/views/home_screen.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MediaStorage.instance.init();
  await initializeDateFormatting();
  runApp(const ProviderScope(child: OurTreeApp()));
}

class OurTreeApp extends StatelessWidget {
  const OurTreeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: buildAppTheme(),
      home: const HomeScreen(),
    );
  }
}
