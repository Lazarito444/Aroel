import 'package:aroel/ui/paper_theme.dart';
import 'package:aroel/ui/tokens.dart';
import 'package:flutter/material.dart';

/// The tone of a notice.
enum NoticeTone {
  /// Something the reader should know.
  info,

  /// Something that went well.
  success,

  /// Something that needs attention.
  warning,

  /// Something that did not work.
  error,
}

/// A quiet message: a hairline of colour and a sentence.
class PaperNotice extends StatelessWidget {
  const PaperNotice(
    this.message, {
    super.key,
    this.tone = NoticeTone.info,
    this.title,
  });

  /// The sentence.
  final String message;

  /// The tone of the notice.
  final NoticeTone tone;

  /// An optional heading.
  final String? title;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperPalette palette = tokens.palette;
    final PaperType type = PaperType.of(context);

    final Color color = switch (tone) {
      NoticeTone.info => palette.accent,
      NoticeTone.success => palette.sage,
      NoticeTone.warning => palette.amber,
      NoticeTone.error => palette.seal,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: Space.sm,
        horizontal: Space.sm,
      ),
      decoration: BoxDecoration(
        color: palette.paperSunk,
        borderRadius: BorderRadius.circular(Radii.input),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(width: 2, height: 36, color: color),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (title != null) ...<Widget>[
                  Text(
                    title!,
                    style: type.uiBodyStrong.copyWith(color: palette.ink),
                  ),
                  const SizedBox(height: Space.xxs),
                ],
                Text(
                  message,
                  style: type.uiBody.copyWith(
                    color: title == null ? palette.ink : palette.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
