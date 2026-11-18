import 'package:aroel/ui/widgets/rating_track.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('one tap sets a value, a second tap on the same stop clears it', (
    WidgetTester tester,
  ) async {
    int? value = 4;
    int taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return RatingTrack(
                  value: value,
                  onChanged: (int? next) {
                    taps++;
                    setState(() => value = next);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    final Rect box = tester.getRect(find.byType(RatingTrack));
    final Offset stop = Offset(box.left + box.width * 0.85, box.center.dy);

    await tester.tapAt(stop);
    await tester.pumpAndSettle();

    expect(taps, 1);
    expect(value, isNot(4));

    await tester.tapAt(stop);
    await tester.pumpAndSettle();

    expect(taps, 2);
    expect(value, isNull);
  });

  testWidgets('the value is named on the trailing edge', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(width: 400, child: RatingTrack(value: 8)),
        ),
      ),
    );

    expect(find.text('4.0 · good'), findsOneWidget);
    expect(find.text('bottom'), findsOneWidget);
    expect(find.text('good day'), findsOneWidget);
  });

  testWidgets('an unrated day says so', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SizedBox(width: 400, child: RatingTrack())),
      ),
    );

    expect(find.text('Not rated'), findsOneWidget);
  });
}
