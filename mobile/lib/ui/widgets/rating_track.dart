import 'package:aroel/ui/paper_theme.dart';
import 'package:aroel/ui/tokens.dart';
import 'package:material_ui/material_ui.dart';

/// The rating control: eleven half steps on a hairline track (§6.6).
///
/// One tap sets a value, a second tap on the same value clears it. The stops are spaced
/// rather than clustered because each one owns a whole segment of the track as its hit
/// target.
class RatingTrack extends StatelessWidget {
  const RatingTrack({
    super.key,
    this.value,
    this.onChanged,
    this.enabled = true,
  });

  /// The chosen value, as a count of half points. `null` means the day is not rated.
  final int? value;

  /// What happens when a stop is tapped. `null` for the unrated value clears the rating.
  final ValueChanged<int?>? onChanged;

  /// Whether the control can be tapped.
  final bool enabled;

  static const double _dot = 7;
  static const double _selected = 20;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 320) {
          return _NarrowTrack(
            value: value,
            onChanged: onChanged,
            enabled: enabled,
          );
        }
        return _WideTrack(value: value, onChanged: onChanged, enabled: enabled);
      },
    );
  }
}

class _WideTrack extends StatelessWidget {
  const _WideTrack({
    required this.value,
    required this.onChanged,
    required this.enabled,
  });

  final int? value;
  final ValueChanged<int?>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperPalette palette = tokens.palette;
    final PaperType type = PaperType.of(context);
    final int? selected = value;

    final String trailing = selected == null ? 'Not rated' : '${RatingStop.valueAt(selected)} · ${RatingStop.labelAt(selected)}';

    return Semantics(
      label: selected == null
          ? 'A rating from 0 to 5. Nothing chosen yet.'
          : 'A rating from 0 to 5. ${RatingStop.valueAt(selected)}, ${RatingStop.labelAt(selected)}. ${RatingStop.at(selected).anchor}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                trailing,
                style: type.label.copyWith(
                  color: selected == null ? palette.inkFaint : palette.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.sm),
          SizedBox(
            height: RatingTrack._selected + 4,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Positioned.fill(
                  child: Center(
                    child: Container(height: 1, color: palette.border),
                  ),
                ),
                Positioned.fill(
                  child: Row(
                    children: List<Widget>.generate(
                      11,
                      (int index) => Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: enabled
                              ? () => onChanged?.call(
                                  selected == index ? null : index,
                                )
                              : null,
                          onLongPress: enabled ? () => _showAnchor(context, index, palette) : null,
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
                ),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints inner) {
                    final double width = inner.maxWidth;
                    final double step = (width - RatingTrack._dot) / (RatingRamp.stops.length - 1);
                    return Stack(
                      children: List<Widget>.generate(RatingRamp.stops.length, (
                        int index,
                      ) {
                        final bool isSelected = selected == index;
                        final double size = isSelected ? RatingTrack._selected : RatingTrack._dot;
                        final double center = index * step + RatingTrack._dot / 2;
                        return Positioned(
                          left: center - size / 2,
                          top: (RatingTrack._selected + 4 - size) / 2,
                          child: Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              color: isSelected ? RatingRamp.colorAt(index) : palette.inkFaint,
                              shape: BoxShape.circle,
                              border: isSelected ? Border.all(color: palette.paper, width: 2) : null,
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('bottom', style: type.caption),
              Text('good day', style: type.caption),
            ],
          ),
        ],
      ),
    );
  }

  void _showAnchor(BuildContext context, int index, PaperPalette palette) {
    final String anchor = RatingStop.at(index).anchor;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(anchor),
          behavior: SnackBarBehavior.floating,
          backgroundColor: palette.ink,
        ),
      );
  }
}

class _NarrowTrack extends StatelessWidget {
  const _NarrowTrack({
    required this.value,
    required this.onChanged,
    required this.enabled,
  });

  final int? value;
  final ValueChanged<int?>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperPalette palette = tokens.palette;
    final PaperType type = PaperType.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(
              value == null ? 'Not rated' : '${RatingStop.valueAt(value!)} · ${RatingStop.labelAt(value!)}',
              style: type.label,
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 1,
            activeTrackColor: value == null ? palette.border : RatingRamp.colorAt(value!),
            inactiveTrackColor: palette.border,
            thumbColor: value == null ? palette.inkFaint : RatingRamp.colorAt(value!),
            overlayColor: Colors.transparent,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: (value ?? 0).toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            label: value == null ? null : RatingStop.valueAt(value!),
            onChanged: enabled
                ? (double next) {
                    final int halfSteps = next.round();
                    onChanged?.call(value == halfSteps ? null : halfSteps);
                  }
                : null,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('bottom', style: type.caption),
            Text('good day', style: type.caption),
          ],
        ),
      ],
    );
  }
}
