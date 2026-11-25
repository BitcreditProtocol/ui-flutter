// With three tabs, tapping the last one while on the first slid past the
// middle page, reported it, and the screen selected it: the tap landed on the
// middle tab instead.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _Harness extends StatefulWidget {
  const _Harness({required this.reported});

  final List<int> reported;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  int index = 0;

  void select(int i) => setState(() => index = i);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            for (var i = 0; i < 3; i++)
              TextButton(onPressed: () => select(i), child: Text('tab $i')),
            Expanded(
              child: SwipeableViews(
                index: index,
                onIndexChanged: (i) {
                  widget.reported.add(i);
                  select(i);
                },
                children: [
                  for (var i = 0; i < 3; i++) Center(child: Text('page $i')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  testWidgets('a tab tap two pages away lands on that page', (tester) async {
    final reported = <int>[];
    await tester.pumpWidget(_Harness(reported: reported));

    await tester.tap(find.text('tab 2'));
    await tester.pumpAndSettle();

    expect(find.text('page 2'), findsOneWidget);
    expect(reported, isEmpty);

    await tester.tap(find.text('tab 0'));
    await tester.pumpAndSettle();

    expect(find.text('page 0'), findsOneWidget);
    expect(reported, isEmpty);
  });

  testWidgets('a swipe still reports the page it lands on', (tester) async {
    final reported = <int>[];
    await tester.pumpWidget(_Harness(reported: reported));

    await tester.fling(find.text('page 0'), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();

    expect(find.text('page 1'), findsOneWidget);
    expect(reported, [1]);
  });
}
