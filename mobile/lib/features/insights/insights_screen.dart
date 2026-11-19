import 'dart:async';

import 'package:aroel/core/day.dart';
import 'package:aroel/core/insights.dart';
import 'package:aroel/ui/paper_theme.dart';
import 'package:aroel/ui/tokens.dart';
import 'package:aroel/ui/widgets/paper_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// The review screens (§5.8): one screen, two windows.
///
/// Weekly shows the last seven days as numbers against the week before; monthly shows
/// the calendar month as a grid of ramp-coloured cells with the same numbers, a per-week
/// breakdown and the month in its best light. Everything is arithmetic over local rows,
/// so the screen renders offline, and an empty window teaches rather than scolds.
class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  int _tab = 0; // 0 == week, 1 == month
  int _monthOffset = 0; // 0 == the month we are in
  List<DayStats>? _window;
  List<DayStats>? _previous;
  List<DayStats>? _month;
  List<DayStats>? _previousMonth;
  EntryRead? _earningEntry;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  String _localDate(DateTime moment) => '${moment.year.toString().padLeft(4, '0')}-${moment.month.toString().padLeft(2, '0')}-${moment.day.toString().padLeft(2, '0')}';

  Future<void> _load() async {
    final DayService service = ref.read(dayServiceProvider);
    final DateTime now = DateTime.now();

    final String today = _localDate(now);
    final List<DayStats> week = await service.statsRange(_localDate(now.subtract(const Duration(days: 6))), today);
    final List<DayStats> prevWeek = await service.statsRange(
      _localDate(now.subtract(const Duration(days: 13))),
      _localDate(now.subtract(const Duration(days: 7))),
    );

    final DateTime monthAnchor = DateTime(now.year, now.month + _monthOffset);
    final DateTime monthStart = DateTime(monthAnchor.year, monthAnchor.month);
    final DateTime monthEnd = DateTime(monthAnchor.year, monthAnchor.month + 1).subtract(const Duration(days: 1));
    final List<DayStats> month = await service.statsRange(_localDate(monthStart), _localDate(monthEnd));
    final DateTime previousStart = DateTime(monthAnchor.year, monthAnchor.month - 1);
    final DateTime previousEnd = DateTime(monthAnchor.year, monthAnchor.month).subtract(const Duration(days: 1));
    final List<DayStats> prevMonth = await service.statsRange(_localDate(previousStart), _localDate(previousEnd));

    EntryRead? earning;
    final List<DayStats> tones = month.where((DayStats day) => day.sentimentHalf != null).toList()..sort((DayStats a, DayStats b) => b.sentimentHalf!.compareTo(a.sentimentHalf!));
    if (tones.isNotEmpty) {
      final List<EntrySummary> entries = await service.entriesOn(tones.first.localDate);
      if (entries.isNotEmpty) {
        earning = await service.readEntryById(entries.first.id);
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _window = week;
      _previous = prevWeek;
      _month = month;
      _previousMonth = prevMonth;
      _earningEntry = earning;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PaperScaffold(
      title: 'Insights',
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.lg, Space.md, Space.lg, 0),
            child: Row(
              children: <Widget>[
                _Segment(label: 'Week', selected: _tab == 0, onTap: () => setState(() => _tab = 0)),
                const SizedBox(width: Space.xs),
                _Segment(label: 'Month', selected: _tab == 1, onTap: () => setState(() => _tab = 1)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(Space.lg),
              children: _tab == 0 ? _weekly() : _monthly(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _weekly() {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);
    final List<DayStats>? window = _window;

    if (window == null) {
      return const <Widget>[SizedBox.shrink()];
    }

    final WindowStat stat = Insights.weekly(window, _previous ?? const <DayStats>[]);
    if (_isEmpty(stat)) {
      return <Widget>[const _EmptyReview(message: 'Rate a day, and the week starts here. Nothing is expected of you before then.')];
    }

    return <Widget>[
      _RatingHeadline(stat: stat, caption: _directionCaption(stat.direction, 'last week'), type: type, tokens: tokens),
      const SizedBox(height: Space.md),
      _StatRow(stat: stat),
      const SizedBox(height: Space.md),
      if (stat.topTags.isNotEmpty) ...<Widget>[
        Text('MOST USED', style: type.label),
        const SizedBox(height: Space.xs),
        Wrap(
          spacing: Space.xs,
          children: <Widget>[
            for (final MapEntry<String, int> tag in stat.topTags) Chip(label: Text('${tag.key} · ${tag.value}')),
          ],
        ),
        const SizedBox(height: Space.md),
      ],
      if (stat.bestDay != null) _BestDayRow(day: stat.bestDay!, onTap: () => context.go('/day/${stat.bestDay!.localDate}')),
      if (stat.sentimentAverage != null) ...<Widget>[
        const SizedBox(height: Space.sm),
        Text(
          'Tone on average · ${stat.sentimentAverage!.toStringAsFixed(1)}',
          style: type.uiBody.copyWith(color: tokens.palette.inkSoft),
        ),
      ],
    ];
  }

  List<Widget> _monthly() {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);
    final List<DayStats>? month = _month;

    if (month == null) {
      return const <Widget>[SizedBox.shrink()];
    }

    final DateTime anchor = DateTime(DateTime.now().year, DateTime.now().month + _monthOffset);
    final String monthKey = '${anchor.year.toString().padLeft(4, '0')}-${anchor.month.toString().padLeft(2, '0')}';
    final MonthGrid grid = Insights.monthGrid(monthKey, month);
    final WindowStat stat = Insights.monthly(month);
    final WindowStat headline = Insights.weekly(month, _previousMonth ?? const <DayStats>[]);

    if (_isEmpty(stat)) {
      return <Widget>[
        _MonthNavigator(
          label: DateFormat('MMMM yyyy').format(anchor),
          onPrevious: () {
            setState(() => _monthOffset -= 1);
            unawaited(_load());
          },
          onNext: _monthOffset < 0
              ? () {
                  setState(() => _monthOffset += 1);
                  unawaited(_load());
                }
              : null,
        ),
        const _EmptyReview(message: 'Rate a day, and the month starts painting itself. Nothing is expected of you before then.'),
      ];
    }

    return <Widget>[
      _MonthNavigator(
        label: DateFormat('MMMM yyyy').format(anchor),
        onPrevious: () {
          setState(() => _monthOffset -= 1);
          unawaited(_load());
        },
        onNext: _monthOffset < 0
            ? () {
                setState(() => _monthOffset += 1);
                unawaited(_load());
              }
            : null,
      ),
      const SizedBox(height: Space.sm),
      _MonthGridView(grid: grid),
      const SizedBox(height: Space.md),
      _RatingHeadline(stat: headline, caption: _directionCaption(headline.direction, 'last month'), type: type, tokens: tokens),
      const SizedBox(height: Space.md),
      _StatRow(stat: headline),
      const SizedBox(height: Space.md),
      Text('WEEK BY WEEK', style: type.label),
      const SizedBox(height: Space.xs),
      for (final WeekBucket bucket in Insights.weeksOf(monthKey, month)) _WeekBucketRow(bucket: bucket),
      const SizedBox(height: Space.md),
      if (stat.bestDay != null) _BestDayRow(day: stat.bestDay!, onTap: () => context.go('/day/${stat.bestDay!.localDate}')),
      if (stat.highestSentimentDay != null) ...<Widget>[
        const SizedBox(height: Space.sm),
        _HighestToneRow(
          day: stat.highestSentimentDay!,
          earningEntry: _earningEntry,
          onTap: _earningEntry == null ? null : () => context.go('/entry/${_earningEntry!.id}'),
        ),
      ],
    ];
  }

  bool _isEmpty(WindowStat stat) => stat.daysRated == 0 && stat.entriesWritten == 0 && stat.gratitudeLines == 0;

  String _directionCaption(double? direction, String other) {
    if (direction == null) {
      return 'first $other yet';
    }
    final double amount = direction.abs();
    if (amount < 0.05) {
      return 'level with $other';
    }
    return direction > 0 ? '${amount.toStringAsFixed(1)} up from $other' : '${amount.toStringAsFixed(1)} down from $other';
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.pill),
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: selected ? tokens.palette.sage.withValues(alpha: 0.18) : tokens.palette.paperSunk,
              borderRadius: BorderRadius.circular(Radii.pill),
              border: Border.all(color: selected ? tokens.palette.sage : tokens.palette.border),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Space.xs),
              child: Center(
                child: Text(
                  label,
                  style: type.uiBodyStrong.copyWith(
                    color: selected ? tokens.palette.sage : tokens.palette.inkSoft,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RatingHeadline extends StatelessWidget {
  const _RatingHeadline({required this.stat, required this.caption, required this.type, required this.tokens});

  final WindowStat stat;
  final String caption;
  final PaperType type;
  final PaperTokens tokens;

  @override
  Widget build(BuildContext context) {
    if (stat.average == null) {
      return Text('Nothing rated', style: type.display.copyWith(color: tokens.palette.inkSoft));
    }

    final int halfSteps = (stat.average! * 2).round().clamp(0, 10);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(stat.average!.toStringAsFixed(1), style: type.display.copyWith(color: RatingRamp.colorAt(halfSteps))),
            const SizedBox(width: Space.xs),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('average', style: type.uiBody.copyWith(color: tokens.palette.inkSoft)),
            ),
          ],
        ),
        const SizedBox(height: Space.xxs),
        Text(caption, style: type.caption.copyWith(color: tokens.palette.inkFaint)),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.stat});

  final WindowStat stat;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);

    Widget cell(String label, String value) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: type.label),
          Text(value, style: type.pageTitle.copyWith(color: tokens.palette.ink)),
        ],
      ),
    );

    return Row(
      children: <Widget>[
        cell('DAYS RATED', '${stat.daysRated}'),
        cell('ENTRIES', '${stat.entriesWritten}'),
        cell('GRATITUDE', '${stat.gratitudeLines}'),
      ],
    );
  }
}

class _BestDayRow extends StatelessWidget {
  const _BestDayRow({required this.day, required this.onTap});

  final DayStats day;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);
    final DateTime date = DateTime.parse(day.localDate);

    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(padding: EdgeInsets.zero),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Best day · ${DateFormat('EEEE d MMMM').format(date)} — ${RatingStop.valueAt(day.ratingHalf!)} · ${RatingStop.labelAt(day.ratingHalf!)}',
          style: type.uiBodyStrong.copyWith(color: tokens.palette.accent),
        ),
      ),
    );
  }
}

class _HighestToneRow extends StatelessWidget {
  const _HighestToneRow({required this.day, this.earningEntry, this.onTap});

  final DayStats day;
  final EntryRead? earningEntry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);
    final DateTime date = DateTime.parse(day.localDate);
    final DayTone? tone = DayTone.at(day.sentimentHalf);

    final Widget label = Text(
      'Highest tone · ${DateFormat('d MMMM').format(date)} — ${tone?.label ?? ''}',
      style: type.uiBodyStrong.copyWith(color: tokens.palette.accent),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextButton(
          onPressed: onTap ?? () {},
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: label,
        ),
        if (earningEntry != null && earningEntry!.body.isNotEmpty) ...<Widget>[
          const SizedBox(height: Space.xxs),
          Text(
            earningEntry!.body.split('\n').first,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: type.prose.copyWith(color: tokens.palette.inkSoft),
          ),
        ],
      ],
    );
  }
}

class _MonthNavigator extends StatelessWidget {
  const _MonthNavigator({required this.label, required this.onPrevious, this.onNext});

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);

    return Row(
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 22),
          color: tokens.palette.ink,
          tooltip: 'Previous month',
          onPressed: onPrevious,
        ),
        Expanded(
          child: Center(
            child: Text(label, style: type.pageTitle.copyWith(color: tokens.palette.ink)),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded, size: 22),
          color: onNext == null ? tokens.palette.border : tokens.palette.ink,
          tooltip: 'Next month',
          onPressed: onNext,
        ),
      ],
    );
  }
}

class _MonthGridView extends StatelessWidget {
  const _MonthGridView({required this.grid});

  final MonthGrid grid;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);
    const List<String> weekday = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            for (final String day in weekday)
              Expanded(
                child: Center(
                  child: Text(day, style: type.caption.copyWith(color: tokens.palette.inkFaint)),
                ),
              ),
          ],
        ),
        const SizedBox(height: Space.xxs),
        for (final List<DayStats?> week in grid.weeks)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.xxs),
            child: Row(
              children: <Widget>[
                for (final DayStats? cell in week) Expanded(child: _MonthCell(cell: cell)),
              ],
            ),
          ),
      ],
    );
  }
}

class _MonthCell extends StatelessWidget {
  const _MonthCell({required this.cell});

  final DayStats? cell;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);

    if (cell == null) {
      return const SizedBox.shrink();
    }

    final DateTime date = DateTime.parse(cell!.localDate);
    final int? halfSteps = cell!.ratingHalf;
    final bool future = cell!.localDate.compareTo(_todayKey()) > 0;

    final Widget body = DecoratedBox(
      decoration: BoxDecoration(
        color: halfSteps == null ? tokens.palette.paperSunk : RatingRamp.colorAt(halfSteps),
        borderRadius: BorderRadius.circular(Radii.chip),
        border: Border.all(color: tokens.palette.border),
      ),
      child: SizedBox(
        height: 52,
        child: Align(
          alignment: Alignment.center,
          child: Text(
            '${date.day}',
            style: type.uiBodyStrong.copyWith(
              color: halfSteps == null || halfSteps >= 2 ? tokens.palette.ink : (halfSteps <= 1 ? tokens.palette.paper : tokens.palette.ink),
            ),
          ),
        ),
      ),
    );

    if (future) {
      return Opacity(opacity: 0.4, child: body);
    }

    return InkWell(
      borderRadius: BorderRadius.circular(Radii.chip),
      onTap: () => context.go('/day/${cell!.localDate}'),
      child: body,
    );
  }

  static String _todayKey() {
    final DateTime now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

class _WeekBucketRow extends StatelessWidget {
  const _WeekBucketRow({required this.bucket});

  final WeekBucket bucket;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);
    final DateTime start = DateTime.parse(bucket.start);
    final DateTime end = DateTime.parse(bucket.end);
    final String range = '${DateFormat('d').format(start)}–${DateFormat('d MMM').format(end)}';

    return Padding(
      padding: const EdgeInsets.only(bottom: Space.xxs),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 84,
            child: Text(range, style: type.uiBody.copyWith(color: tokens.palette.inkSoft)),
          ),
          Expanded(
            child: Text(
              bucket.average == null ? '—' : bucket.average!.toStringAsFixed(1),
              style: type.uiBodyStrong.copyWith(color: tokens.palette.ink),
            ),
          ),
          Text(
            '${bucket.daysRated} rated · ${bucket.entriesWritten} written',
            style: type.caption.copyWith(color: tokens.palette.inkFaint),
          ),
        ],
      ),
    );
  }
}

class _EmptyReview extends StatelessWidget {
  const _EmptyReview({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.xl),
      child: Text(
        message,
        style: type.prose.copyWith(color: tokens.palette.inkSoft),
      ),
    );
  }
}
