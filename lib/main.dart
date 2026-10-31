import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ourtree_app/core/firebase/firebase_bootstrap.dart';
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/core/storage/app_migrations.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/identity_provider.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_sync_provider.dart';
import 'package:ourtree_app/features/family/presentation/views/home_screen.dart';
import 'package:ourtree_app/features/settings/presentation/providers/locale_provider.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MediaStorage.instance.init();
  // Миграция локальной схемы: `account-<micros>` → UUID v4 и перенос ссылок.
  await AppMigrations().run();
  // Firebase необязателен для старта: при сбое приложение работает офлайн.
  await FirebaseBootstrap.init();
  await initializeDateFormatting();
  runApp(const ProviderScope(child: OurTreeApp()));
}

class OurTreeApp extends ConsumerWidget {
  const OurTreeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Анонимный вход выполняется при старте: без auth.uid не работают
    // Security Rules. Ошибка сети не блокирует офлайн-режим приложения.
    ref.watch(identityControllerProvider);
    // Синхронизация текстов архива: включается только при подключённой семье.
    ref.watch(familySyncControllerProvider);

    return MaterialApp(
      // Итоговый язык: выбранный в настройках или язык системы.
      locale: ref.watch(appLocaleProvider),
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: buildAppTheme(),
      home: const HomeScreen(),
    );
  }
}
