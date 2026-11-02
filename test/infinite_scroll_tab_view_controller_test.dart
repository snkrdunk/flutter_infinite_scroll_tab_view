import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_tab_view/infinite_scroll_tab_view.dart';

void main() {
  const tabs = ['A', 'B', 'C', 'D'];

  Widget buildTarget(
    InfiniteScrollTabViewController controller, {
    ValueChanged<int>? onPageChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: InfiniteScrollTabView(
          controller: controller,
          contentLength: tabs.length,
          onPageChanged: onPageChanged,
          tabBuilder: (index, isSelected) => Text(tabs[index]),
          pageBuilder: (context, index, isSelected) =>
              Center(child: Text('page ${tabs[index]}')),
        ),
      ),
    );
  }

  group('InfiniteScrollTabViewController', () {
    testWidgets('ウィジェットに接続され、初期の選択インデックスは0になる。', (tester) async {
      final controller = InfiniteScrollTabViewController();
      expect(controller.isAttached, isFalse);
      expect(controller.selectedIndex, isNull);

      await tester.pumpWidget(buildTarget(controller));

      expect(controller.isAttached, isTrue);
      expect(controller.selectedIndex, 0);
    });

    testWidgets('jumpToIndex で指定したタブへ移動する。', (tester) async {
      final controller = InfiniteScrollTabViewController();
      await tester.pumpWidget(buildTarget(controller));

      await controller.jumpToIndex(2);
      await tester.pumpAndSettle();

      expect(controller.selectedIndex, 2);
    });

    testWidgets('animateToIndex で指定したタブへ移動する。', (tester) async {
      final controller = InfiniteScrollTabViewController();
      await tester.pumpWidget(buildTarget(controller));

      final future = controller.animateToIndex(1);
      await tester.pumpAndSettle();
      await future;

      expect(controller.selectedIndex, 1);
    });

    testWidgets('範囲外のインデックスを指定しても選択タブは変わらない。', (tester) async {
      final controller = InfiniteScrollTabViewController();
      await tester.pumpWidget(buildTarget(controller));

      await controller.jumpToIndex(-1);
      await controller.jumpToIndex(tabs.length);
      await tester.pumpAndSettle();

      expect(controller.selectedIndex, 0);
    });

    testWidgets('animateToIndex では通過するタブで onPageChanged が呼ばれない。',
        (tester) async {
      final controller = InfiniteScrollTabViewController();
      final changedIndexes = <int>[];
      await tester.pumpWidget(
        buildTarget(controller, onPageChanged: changedIndexes.add),
      );

      final future = controller.animateToIndex(3);
      await tester.pumpAndSettle();
      await future;

      expect(changedIndexes, [3]);
      expect(controller.selectedIndex, 3);
    });

    testWidgets('jumpToIndex でも onPageChanged は一度だけ呼ばれる。', (tester) async {
      final controller = InfiniteScrollTabViewController();
      final changedIndexes = <int>[];
      await tester.pumpWidget(
        buildTarget(controller, onPageChanged: changedIndexes.add),
      );

      await controller.jumpToIndex(2);
      await tester.pumpAndSettle();

      expect(changedIndexes, [2]);
      expect(controller.selectedIndex, 2);
    });

    testWidgets('ウィジェットが破棄されると接続も外れる。', (tester) async {
      final controller = InfiniteScrollTabViewController();
      await tester.pumpWidget(buildTarget(controller));
      expect(controller.isAttached, isTrue);

      await tester.pumpWidget(const SizedBox.shrink());

      expect(controller.isAttached, isFalse);
      expect(controller.selectedIndex, isNull);
    });
  });
}
