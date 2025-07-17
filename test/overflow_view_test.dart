import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:overflow_view/overflow_view.dart';

void main() {
  testWidgets(
    'the overflow indicator is not built if there is enough room',
    (tester) async {
      int buildCount = 0;
      await tester.pumpWidget(
        Center(
          child: SizedBox(
            width: 100,
            child: OverflowView(
              builder: (context, count) {
                buildCount++;
                return const SizedBox();
              },
              children: [const SizedBox(width: 100)],
            ),
          ),
        ),
      );
      expect(buildCount, 0);

      await tester.pumpWidget(
        Center(
          child: SizedBox(
            width: 100,
            child: OverflowView.flexible(
              builder: (context, count) {
                buildCount++;
                return const SizedBox();
              },
              children: [const SizedBox(width: 100)],
            ),
          ),
        ),
      );
      expect(buildCount, 0);
    },
  );

  testWidgets(
    'the overflow indicator is built if there is not enough room',
    (tester) async {
      int buildCount = 0;
      late int remainingCount;
      await tester.pumpWidget(
        Center(
          child: SizedBox(
            width: 100,
            child: OverflowView(
              builder: (context, count) {
                buildCount++;
                remainingCount = count;
                return const SizedBox();
              },
              children: [
                const SizedBox(width: 50),
                const SizedBox(width: 50),
                const SizedBox(width: 50),
                const SizedBox(width: 50),
              ],
            ),
          ),
        ),
      );
      expect(buildCount, 1);
      expect(remainingCount, 3);

      buildCount = 0;

      await tester.pumpWidget(
        Center(
          child: SizedBox(
            width: 100,
            child: OverflowView.flexible(
              builder: (context, count) {
                buildCount++;
                remainingCount = count;
                return const SizedBox(width: 30);
              },
              children: [
                const SizedBox(width: 50),
                const SizedBox(width: 20),
                const SizedBox(width: 50),
                const SizedBox(width: 50),
              ],
            ),
          ),
        ),
      );
      expect(buildCount, 1);
      expect(remainingCount, 2);
    },
  );

  testWidgets(
    'children are layed out according to direction',
    (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              height: 100,
              width: 100,
              child: OverflowView(
                builder: (context, count) {
                  return const SizedBox();
                },
                children: [
                  const _Text('A'),
                  const _Text('B'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.getTopLeft(find.text('A')), const Offset(0, 0));
      expect(tester.getTopLeft(find.text('B')), const Offset(50, 0));

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              height: 100,
              width: 100,
              child: OverflowView(
                direction: Axis.vertical,
                builder: (context, count) {
                  return const SizedBox();
                },
                children: [
                  const _Text('A'),
                  const _Text('B'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.getTopLeft(find.text('A')), const Offset(0, 0));
      expect(tester.getTopLeft(find.text('B')), const Offset(0, 50));
    },
  );

  testWidgets(
    'children are layed out according to direction and spacing',
    (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              height: 110,
              width: 110,
              child: OverflowView(
                spacing: 10,
                builder: (context, count) {
                  return const SizedBox();
                },
                children: [
                  const _Text('A'),
                  const _Text('B'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.getTopLeft(find.text('A')), const Offset(0, 0));
      expect(tester.getTopLeft(find.text('B')), const Offset(60, 0));

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              height: 110,
              width: 110,
              child: OverflowView(
                spacing: 10,
                direction: Axis.vertical,
                builder: (context, count) {
                  return const SizedBox();
                },
                children: [
                  const _Text('A'),
                  const _Text('B'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.getTopLeft(find.text('A')), const Offset(0, 0));
      expect(tester.getTopLeft(find.text('B')), const Offset(0, 60));

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              height: 110,
              width: 110,
              child: OverflowView.flexible(
                spacing: 10,
                builder: (context, count) {
                  return const SizedBox();
                },
                children: [
                  const _Text('A'),
                  const _Text('B'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.getTopLeft(find.text('A')), const Offset(0, 0));
      expect(tester.getTopLeft(find.text('B')), const Offset(60, 0));

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              height: 110,
              width: 110,
              child: OverflowView.flexible(
                spacing: 10,
                direction: Axis.vertical,
                builder: (context, count) {
                  return const SizedBox();
                },
                children: [
                  const _Text('A'),
                  const _Text('B'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.getTopLeft(find.text('A')), const Offset(0, 0));
      expect(tester.getTopLeft(find.text('B')), const Offset(0, 60));
    },
  );

  testWidgets(
    'spacing can be negative for overlapping effect',
    (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              height: 110,
              width: 110,
              child: OverflowView(
                spacing: -10,
                builder: (context, count) {
                  return const SizedBox();
                },
                children: [
                  const _Text('A'),
                  const _Text('B'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.getTopLeft(find.text('A')), const Offset(0, 0));
      expect(tester.getTopLeft(find.text('B')), const Offset(40, 0));
    },
  );

  testWidgets(
    'OverflowView.flexible should build builder twice if there is not enough room for it the first time',
    (tester) async {
      int buildCount = 0;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              height: 150,
              width: 150,
              child: OverflowView.flexible(
                builder: (context, count) {
                  buildCount++;
                  return const SizedBox(
                    width: 100,
                  );
                },
                children: [
                  const _Text('A'),
                  const _Text('B'),
                  const _Text('C'),
                  const _Text('D'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(buildCount, 2);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsNothing);
      expect(find.text('C'), findsNothing);
      expect(find.text('E'), findsNothing);
    },
  );

  testWidgets(
    'unmount successfully the overflow indicator once it has already been laid '
    'out with .flexible()',
    (tester) async {
      await tester.pumpWidget(
        Center(
          child: SizedBox(
            width: 100,
            child: OverflowView.flexible(
              builder: (context, count) {
                return const SizedBox(width: 30);
              },
              children: [
                const SizedBox(width: 50),
                const SizedBox(width: 20),
                const SizedBox(width: 50),
                const SizedBox(width: 50),
              ],
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        Center(
          child: SizedBox(
            width: 100,
            child: OverflowView.flexible(
              builder: (context, count) {
                return const SizedBox(width: 30);
              },
              children: [
                const SizedBox(width: 50),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _Text extends StatelessWidget {
  const _Text(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 50,
      child: Text(text),
    );
  }
}
