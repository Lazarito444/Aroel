import 'package:aroel/app/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// The appearance of the app: light, dark or whatever the device says (§5.9).
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.watch(initialThemeModeProvider);

  /// Chooses the appearance and keeps the choice.
  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await ref.read(databaseProvider).writePreference(AppearanceKeys.themeMode, mode.name);
  }
}

/// The names of the preferences the appearance is kept in.
abstract final class AppearanceKeys {
  /// The appearance the reader chose.
  static const String themeMode = 'appearance.theme_mode';
}

/// The appearance as it was read at launch.
final Provider<ThemeMode> initialThemeModeProvider = Provider<ThemeMode>(
  (Ref ref) => throw StateError('The appearance has to be read before the app starts.'),
);

/// The appearance of the app.
final NotifierProvider<ThemeModeController, ThemeMode> themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
