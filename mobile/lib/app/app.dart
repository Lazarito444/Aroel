import 'package:aroel/app/router.dart';
import 'package:aroel/features/settings/theme_controller.dart';
import 'package:aroel/ui/paper_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// The app.
class AroelApp extends ConsumerWidget {
  const AroelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode mode = ref.watch(themeModeProvider);

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
