import 'package:flutter/material.dart';

/// The Warm Paper palette (§6.1).
///
/// Every colour in the app comes from here. There are no arbitrary colours: the ramp is
/// the only place where colour carries meaning, and it stays inside this palette.
@immutable
class PaperPalette {
  const PaperPalette({
    required this.paper,
    required this.paperRaised,
    required this.paperSunk,
    required this.ink,
    required this.inkSoft,
    required this.inkFaint,
    required this.accent,
    required this.seal,
    required this.sage,
    required this.amber,
    required this.border,
  });

  /// The palette the app uses in light mode.
  static const PaperPalette light = PaperPalette(
    paper: Color(0xFFF6F1E7),
    paperRaised: Color(0xFFFFFBF3),
    paperSunk: Color(0xFFEDE5D6),
    ink: Color(0xFF241C15),
    inkSoft: Color(0xFF5B5147),
    inkFaint: Color(0xFF8C8175),
    accent: Color(0xFF7A4E2D),
    seal: Color(0xFFA6402F),
    sage: Color(0xFF6E7B5B),
    amber: Color(0xFFC08A2E),
    border: Color(0xFFE2D8C6),
  );

  /// The palette the app uses in dark mode.
  static const PaperPalette dark = PaperPalette(
    paper: Color(0xFF14110E),
    paperRaised: Color(0xFF1E1A15),
    paperSunk: Color(0xFF0E0C09),
    ink: Color(0xFFEFE6D8),
    inkSoft: Color(0xFFB9AD9C),
    inkFaint: Color(0xFF8A7F71),
    accent: Color(0xFFC98B5A),
    seal: Color(0xFFD96A55),
    sage: Color(0xFF8E9C78),
    amber: Color(0xFFD9A64B),
    border: Color(0xFF2A241D),
  );

  /// The app's ground.
  final Color paper;

  /// Cards and sheets.
  final Color paperRaised;

  /// Inputs, chips and wells.
  final Color paperSunk;

  /// Primary text.
  final Color ink;

  /// Secondary text.
  final Color inkSoft;

  /// Metadata and placeholders.
  final Color inkFaint;

  /// Primary actions and links.
  final Color accent;

  /// Destructive actions and hard days.
  final Color seal;

  /// Success, calm, good days.
  final Color sage;

  /// Warnings and mid mood.
  final Color amber;

  /// Hairline dividers.
  final Color border;

  /// The colour of a rating at [halfSteps], where 0 is 0.0 and 10 is 5.0.
  Color rating(int halfSteps) => RatingRamp.colorAt(halfSteps);

  /// The colour of the text that sits on top of a rating at [halfSteps].
  ///
  /// Only the two darkest warm steps take paper-coloured numerals; the middle of the ramp
  /// is far too light for white type (§6.6).
  Color onRating(int halfSteps) => halfSteps <= 1 ? paper : const Color(0xFF241C15);
}

/// The spacing steps (§6.3). Nothing between these.
abstract final class Space {
  /// Four points.
  static const double xxs = 4;

  /// Eight points.
  static const double xs = 8;

  /// Twelve points.
  static const double sm = 12;

  /// Sixteen points.
  static const double md = 16;

  /// Twenty-four points.
  static const double lg = 24;

  /// Thirty-two points.
  static const double xl = 32;

  /// Forty-eight points.
  static const double xxl = 48;
}

/// The radii (§6.3).
abstract final class Radii {
  /// Chips.
  static const double chip = 8;

  /// Inputs.
  static const double input = 12;

  /// Cards.
  static const double card = 16;

  /// Sheets.
  static const double sheet = 24;

  /// Pills.
  static const double pill = 999;
}

/// The durations of the three motions the app has (§6.4).
abstract final class Motion {
  /// Presses: a scale to .98.
  static const Duration press = Duration(milliseconds: 120);

  /// Sheets and card expansion.
  static const Duration sheet = Duration(milliseconds: 220);

  /// Page pushes.
  static const Duration page = Duration(milliseconds: 320);
}

/// The elevation shadows, warm-tinted and never neutral grey (§6.3).
@immutable
class PaperElevation {
  const PaperElevation({
    required this.e1,
    required this.e2,
    required this.sheet,
  });

  /// The shadow of a card.
  final List<BoxShadow> e1;

  /// The shadow of a raised surface.
  final List<BoxShadow> e2;

  /// The shadow of a sheet.
  final List<BoxShadow> sheet;

  /// The shadows of the light palette.
  static const PaperElevation light = PaperElevation(
    e1: [
      BoxShadow(
        color: Color(0x0F3C2814),
        blurRadius: 2,
        spreadRadius: 0,
        offset: Offset(0, 1),
      ),
    ],
    e2: [
      BoxShadow(
        color: Color(0x143C2814),
        blurRadius: 24,
        spreadRadius: 0,
        offset: Offset(0, 8),
      ),
    ],
    sheet: [
      BoxShadow(
        color: Color(0x1A3C2814),
        blurRadius: 32,
        spreadRadius: 0,
        offset: Offset(0, -8),
      ),
    ],
  );

  /// The shadows of the dark palette.
  static const PaperElevation dark = PaperElevation(
    e1: [
      BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 2,
        spreadRadius: 0,
        offset: Offset(0, 1),
      ),
    ],
    e2: [
      BoxShadow(
        color: Color(0x26000000),
        blurRadius: 24,
        spreadRadius: 0,
        offset: Offset(0, 8),
      ),
    ],
    sheet: [
      BoxShadow(
        color: Color(0x33000000),
        blurRadius: 32,
        spreadRadius: 0,
        offset: Offset(0, -8),
      ),
    ],
  );
}

/// The eleven stops of the rating ramp (§6.6).
///
/// The ramp diverges around 2.5, not 3, and stays inside the palette so a hard week
/// reads as warm rather than as an error state.
abstract final class RatingRamp {
  /// The colour of every half step, from 0.0 to 5.0.
  static const List<Color> stops = <Color>[
    Color(0xFF9E3B2B), // 0.0
    Color(0xFFA95B41), // 0.5
    Color(0xFFB77A5A), // 1.0
    Color(0xFFC29675), // 1.5
    Color(0xFFCDB098), // 2.0
    Color(0xFFD8CDB8), // 2.5
    Color(0xFFC4C3A6), // 3.0
    Color(0xFFB0B996), // 3.5
    Color(0xFF9AA382), // 4.0
    Color(0xFF84906F), // 4.5
    Color(0xFF6E7B5B), // 5.0
  ];

  /// The colour of the stop at [halfSteps], where 0 is 0.0 and 10 is 5.0.
  static Color colorAt(int halfSteps) => stops[halfSteps.clamp(0, stops.length - 1)];
}

/// One stop of the rating scale, with the words that explain it (§4.5).
@immutable
class RatingStop {
  const RatingStop({
    required this.halfSteps,
    required this.value,
    required this.label,
    required this.anchor,
  });

  /// The stop's place on the scale, as a count of half points.
  final int halfSteps;

  /// The value as it is written, e.g. `4.0`.
  final String value;

  /// The name of the stop, e.g. `good`.
  final String label;

  /// The sentence that explains the stop.
  final String anchor;

  /// The eleven stops, in order.
  static const List<RatingStop> all = <RatingStop>[
    RatingStop(
      halfSteps: 0,
      value: '0.0',
      label: 'bottom',
      anchor: "A day I'd rather not repeat.",
    ),
    RatingStop(
      halfSteps: 1,
      value: '0.5',
      label: 'bottom',
      anchor: "A day I'd rather not repeat.",
    ),
    RatingStop(
      halfSteps: 2,
      value: '1.0',
      label: 'hard',
      anchor: 'It cost me something.',
    ),
    RatingStop(
      halfSteps: 3,
      value: '1.5',
      label: 'hard',
      anchor: 'It cost me something.',
    ),
    RatingStop(
      halfSteps: 4,
      value: '2.0',
      label: 'off',
      anchor: 'Below an ordinary day.',
    ),
    RatingStop(
      halfSteps: 5,
      value: '2.5',
      label: 'ordinary',
      anchor: 'Neither good nor bad. A day.',
    ),
    RatingStop(
      halfSteps: 6,
      value: '3.0',
      label: 'okay',
      anchor: 'Fine. A little better than a day.',
    ),
    RatingStop(
      halfSteps: 7,
      value: '3.5',
      label: 'okay',
      anchor: 'Fine. A little better than a day.',
    ),
    RatingStop(
      halfSteps: 8,
      value: '4.0',
      label: 'good',
      anchor: "I'd take another one like it.",
    ),
    RatingStop(
      halfSteps: 9,
      value: '4.5',
      label: 'good',
      anchor: "I'd take another one like it.",
    ),
    RatingStop(
      halfSteps: 10,
      value: '5.0',
      label: 'one of the best',
      anchor: 'One of the good ones.',
    ),
  ];

  /// The stop at [halfSteps].
  static RatingStop at(int halfSteps) => all[halfSteps.clamp(0, all.length - 1)];

  /// The name of the stop at [halfSteps], e.g. `good`.
  static String labelAt(int halfSteps) => at(halfSteps).label;

  /// The value at [halfSteps], written the way the app writes it, e.g. `4.0`.
  static String valueAt(int halfSteps) => at(halfSteps).value;
}
