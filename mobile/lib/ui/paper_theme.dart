import 'package:aroel/ui/tokens.dart';
import 'package:flutter/material.dart';

/// The colours and shadows of the current mode.
///
/// Widgets read the palette from here instead of hard-coding hex values, so light and
/// dark mode stay in step and no screen invents a colour.
@immutable
class PaperTokens extends ThemeExtension<PaperTokens> {
  const PaperTokens({required this.palette, required this.elevation});

  /// The tokens of the light mode.
  static const PaperTokens light = PaperTokens(
    palette: PaperPalette.light,
    elevation: PaperElevation.light,
  );

  /// The tokens of the dark mode.
  static const PaperTokens dark = PaperTokens(
    palette: PaperPalette.dark,
    elevation: PaperElevation.dark,
  );

  /// The palette.
  final PaperPalette palette;

  /// The shadows.
  final PaperElevation elevation;

  /// The tokens in force at [context].
  static PaperTokens of(BuildContext context) => Theme.of(context).extension<PaperTokens>() ?? light;

  @override
  PaperTokens copyWith({PaperPalette? palette, PaperElevation? elevation}) => PaperTokens(
    palette: palette ?? this.palette,
    elevation: elevation ?? this.elevation,
  );

  @override
  PaperTokens lerp(ThemeExtension<PaperTokens>? other, double t) {
    if (other is! PaperTokens) {
      return this;
    }
    return PaperTokens(
      palette: t < 0.5 ? palette : other.palette,
      elevation: t < 0.5 ? elevation : other.elevation,
    );
  }
}

/// The type roles of the app (§6.2).
///
/// Newsreader carries the prose and the headings; Inter carries the chrome. The roles are
/// named so that prose can never be set in Inter by accident.
@immutable
class PaperType extends ThemeExtension<PaperType> {
  const PaperType({
    required this.display,
    required this.pageTitle,
    required this.prose,
    required this.proseItalic,
    required this.uiBody,
    required this.uiBodyStrong,
    required this.label,
    required this.caption,
  });

  /// The type roles of the light mode.
  static PaperType light = PaperType.forPalette(PaperPalette.light);

  /// The type roles of the dark mode.
  static PaperType dark = PaperType.forPalette(PaperPalette.dark);

  /// Builds the roles for [palette].
  factory PaperType.forPalette(PaperPalette palette) => PaperType(
    display: TextStyle(
      fontFamily: 'Newsreader',
      fontSize: 28,
      height: 32 / 28,
      fontWeight: FontWeight.w400,
      color: palette.ink,
    ),
    pageTitle: TextStyle(
      fontFamily: 'Newsreader',
      fontSize: 22,
      height: 28 / 22,
      fontWeight: FontWeight.w500,
      color: palette.ink,
    ),
    prose: TextStyle(
      fontFamily: 'Newsreader',
      fontSize: 17,
      height: 28 / 17,
      fontWeight: FontWeight.w400,
      color: palette.ink,
    ),
    proseItalic: TextStyle(
      fontFamily: 'Newsreader',
      fontSize: 17,
      height: 28 / 17,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic,
      color: palette.ink,
    ),
    uiBody: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w400,
      color: palette.ink,
    ),
    uiBodyStrong: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w500,
      color: palette.ink,
    ),
    label: TextStyle(
      fontFamily: 'Inter',
      fontSize: 11,
      height: 16 / 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.06,
      color: palette.inkSoft,
    ),
    caption: TextStyle(
      fontFamily: 'Inter',
      fontSize: 11,
      height: 16 / 11,
      fontWeight: FontWeight.w400,
      color: palette.inkFaint,
    ),
  );

  /// The greeting: Newsreader 28/32.
  final TextStyle display;

  /// The page title: Newsreader 22/28, medium.
  final TextStyle pageTitle;

  /// What the reader wrote: Newsreader 17/28.
  final TextStyle prose;

  /// What the reader wrote, in italics.
  final TextStyle proseItalic;

  /// Interface text: Inter 14/20.
  final TextStyle uiBody;

  /// Interface text with weight.
  final TextStyle uiBodyStrong;

  /// Labels: Inter 11/16, uppercase, spaced.
  final TextStyle label;

  /// Captions: Inter 11/16.
  final TextStyle caption;

  /// The type roles in force at [context].
  static PaperType of(BuildContext context) => Theme.of(context).extension<PaperType>() ?? light;

  @override
  PaperType copyWith({
    TextStyle? display,
    TextStyle? pageTitle,
    TextStyle? prose,
    TextStyle? proseItalic,
    TextStyle? uiBody,
    TextStyle? uiBodyStrong,
    TextStyle? label,
    TextStyle? caption,
  }) => PaperType(
    display: display ?? this.display,
    pageTitle: pageTitle ?? this.pageTitle,
    prose: prose ?? this.prose,
    proseItalic: proseItalic ?? this.proseItalic,
    uiBody: uiBody ?? this.uiBody,
    uiBodyStrong: uiBodyStrong ?? this.uiBodyStrong,
    label: label ?? this.label,
    caption: caption ?? this.caption,
  );

  @override
  PaperType lerp(ThemeExtension<PaperType>? other, double t) => t < 0.5 ? this : (other as PaperType? ?? this);
}

/// Builds the Material theme from the Warm Paper tokens.
abstract final class PaperTheme {
  /// The theme of the light mode.
  static ThemeData get light => _build(Brightness.light);

  /// The theme of the dark mode.
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final PaperTokens tokens = isDark ? PaperTokens.dark : PaperTokens.light;
    final PaperPalette palette = tokens.palette;
    final PaperType type = isDark ? PaperType.dark : PaperType.light;

    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: palette.accent,
      onPrimary: palette.paper,
      secondary: palette.sage,
      onSecondary: palette.paper,
      error: palette.seal,
      onError: palette.paper,
      surface: palette.paper,
      onSurface: palette.ink,
      surfaceContainerHighest: palette.paperSunk,
      onSurfaceVariant: palette.inkSoft,
      outline: palette.border,
      outlineVariant: palette.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: palette.paper,
      canvasColor: palette.paper,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      fontFamily: 'Inter',
      textTheme: TextTheme(
        displayLarge: type.display,
        headlineSmall: type.pageTitle,
        bodyLarge: type.prose,
        bodyMedium: type.uiBody,
        labelSmall: type.label,
        bodySmall: type.caption,
      ).apply(bodyColor: palette.ink, displayColor: palette.ink),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.paper,
        foregroundColor: palette.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: type.pageTitle,
      ),
      dividerTheme: DividerThemeData(
        color: palette.border,
        thickness: 1,
        space: 1,
      ),
      extensions: <ThemeExtension<dynamic>>[tokens, type],
    );
  }
}
