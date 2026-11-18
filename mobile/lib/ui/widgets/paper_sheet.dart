import 'package:aroel/ui/paper_theme.dart';
import 'package:aroel/ui/tokens.dart';
import 'package:material_ui/material_ui.dart';

/// Shows a sheet in the app's shape: paper raised, a 24 radius, a warm shadow.
Future<T?> showPaperSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  final PaperTokens tokens = PaperTokens.of(context);

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x333C2814),
    transitionAnimationController: AnimationController(
      vsync: Navigator.of(context),
      duration: Motion.sheet,
      reverseDuration: Motion.sheet,
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: tokens.palette.paperRaised,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(Radii.sheet),
            ),
            boxShadow: tokens.elevation.sheet,
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(Space.lg),
              child: builder(context),
            ),
          ),
        ),
      );
    },
  );
}

/// The heading of a sheet.
class PaperSheetTitle extends StatelessWidget {
  const PaperSheetTitle(this.title, {super.key, this.subtitle});

  /// The words that name the sheet.
  final String title;

  /// A line that says what the sheet is for.
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final PaperType type = PaperType.of(context);
    final PaperTokens tokens = PaperTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: type.pageTitle),
        if (subtitle != null) ...<Widget>[
          const SizedBox(height: Space.xs),
          Text(
            subtitle!,
            style: type.uiBody.copyWith(color: tokens.palette.inkSoft),
          ),
        ],
      ],
    );
  }
}
