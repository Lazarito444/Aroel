import 'package:aroel/core/day.dart';
import 'package:aroel/ui/paper_theme.dart';
import 'package:aroel/ui/tokens.dart';
import 'package:aroel/ui/widgets/paper_sheet.dart';
import 'package:material_ui/material_ui.dart';

/// The tone picker (§4.6): how the day read, in the reader's own words.
///
/// A hand pick wins over a derived one. Neutral words, never diagnosis language (§10.5).
/// A second tap on the chosen tone clears it.
class TonePicker extends StatelessWidget {
  const TonePicker({
    required this.sentimentHalf,
    required this.onChanged,
    super.key,
  });

  /// The tone on the half point scale, `null` when none was picked.
  final int? sentimentHalf;

  /// What happens when a tone is tapped; `null` clears the tone.
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);
    final DayTone? current = DayTone.at(sentimentHalf);

    return InkWell(
      borderRadius: BorderRadius.circular(Radii.chip),
      onTap: () => _showSheet(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.xs),
        child: Row(
          children: <Widget>[
            Icon(
              current == null ? Icons.water_drop_outlined : Icons.water_drop,
              size: 18,
              color: current == null ? tokens.palette.inkFaint : RatingRamp.colorAt(sentimentHalf!),
            ),
            const SizedBox(width: Space.xs),
            Text(
              current == null ? 'HOW DID IT READ?' : 'TONE · ${current.label.toUpperCase()}',
              style: type.label.copyWith(
                color: current == null ? tokens.palette.inkFaint : tokens.palette.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSheet(BuildContext context) async {
    await showPaperSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        final PaperType sheetType = PaperType.of(sheetContext);
        final PaperTokens sheetTokens = PaperTokens.of(sheetContext);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const PaperSheetTitle('How did the day read?'),
            const SizedBox(height: Space.md),
            for (int index = DayTone.all.length - 1; index >= 0; index--)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  DayTone.all[index].label,
                  style: sheetType.prose.copyWith(color: sheetTokens.palette.ink),
                ),
                trailing: DayTone.all[index].matches(sentimentHalf) ? Icon(Icons.check_rounded, size: 20, color: sheetTokens.palette.sage) : null,
                onTap: () {
                  final bool chosen = DayTone.all[index].matches(sentimentHalf);
                  onChanged(chosen ? null : DayTone.all[index].ratingHalf);
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        );
      },
    );
  }
}
