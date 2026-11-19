import 'dart:async';

import 'package:aroel/app/providers.dart';
import 'package:aroel/app/router.dart';
import 'package:aroel/core/account.dart';
import 'package:aroel/core/account_controller.dart';
import 'package:aroel/features/settings/theme_controller.dart';
import 'package:aroel/ui/paper_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// The app.
class AroelApp extends ConsumerStatefulWidget {
  const AroelApp({super.key});

  @override
  ConsumerState<AroelApp> createState() => _AroelAppState();
}

class _AroelAppState extends ConsumerState<AroelApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // A launch sync, when the account is ready to sync; a plain no-op otherwise.
      unawaited(ref.read(syncEngineProvider).syncNow());
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeMode mode = ref.watch(themeModeProvider);

    ref.listen(accountControllerProvider, (previous, next) {
      if (previous?.account.status != AccountStatus.signedIn && next.account.status == AccountStatus.signedIn) {
        unawaited(ref.read(syncEngineProvider).syncNow());
      }
    });

    return MaterialApp.router(
      title: 'Aroel',
      debugShowCheckedModeBanner: false,
      theme: PaperTheme.light,
      darkTheme: PaperTheme.dark,
      themeMode: mode,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
