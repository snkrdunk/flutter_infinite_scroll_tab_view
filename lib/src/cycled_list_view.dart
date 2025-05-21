import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

typedef ModuloIndexedWidgetBuilder = Widget Function(
    BuildContext context, int modIndex, int rawIndex);

class CycledListView extends StatefulWidget {
  /// [ListView.builder] を参照してください。
  const CycledListView.builder({
    Key? key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.physics,
    this.padding,
    required this.itemBuilder,
    required this.contentCount,
    this.itemCount,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.anchor = 0.0,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
  }) : super(key: key);

  /// [ScrollView.scrollDirection] を参照してください。
  final Axis scrollDirection;

  /// [ScrollView.reverse] を参照してください。
  final bool reverse;

  /// [ScrollView.controller] を参照してください。
  final CycledScrollController? controller;

  /// [ScrollView.physics] を参照してください。
  final ScrollPhysics? physics;

  /// [BoxScrollView.padding] を参照してください。
  final EdgeInsets? padding;

  /// [ListView.builder] を参照してください。
  final ModuloIndexedWidgetBuilder itemBuilder;

  /// [SliverChildBuilderDelegate.childCount] を参照してください。
  final int? itemCount;

  /// [ScrollView.cacheExtent] を参照してください。
  final double? cacheExtent;

  /// [ScrollView.anchor] を参照してください。
  final double anchor;

  /// [SliverChildBuilderDelegate.addAutomaticKeepAlives] を参照してください。
  final bool addAutomaticKeepAlives;

  /// [SliverChildBuilderDelegate.addRepaintBoundaries] を参照してください。
  final bool addRepaintBoundaries;

  /// [SliverChildBuilderDelegate.addSemanticIndexes] を参照してください。
  final bool addSemanticIndexes;

  /// [ScrollView.dragStartBehavior] を参照してください。
  final DragStartBehavior dragStartBehavior;

  /// [ScrollView.keyboardDismissBehavior] を参照してください。
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// [ScrollView.restorationId] を参照してください。
  final String? restorationId;

  /// [ScrollView.clipBehavior] を参照してください。
  final Clip clipBehavior;

  final int contentCount;

  @override
  _CycledListViewState createState() => _CycledListViewState();
}

class _CycledListViewState extends State<CycledListView> {
  CycledScrollController? _controller;

  CycledScrollController get _effectiveController =>
      widget.controller ?? _controller!;

  UniqueKey positiveListKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = CycledScrollController(initialScrollOffset: 0.0);
    }
  }

  @override
  void didUpdateWidget(CycledListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && oldWidget.controller != null) {
      _controller = CycledScrollController(initialScrollOffset: 0.0);
    } else if (widget.controller != null && oldWidget.controller == null) {
      _controller!.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> slivers = _buildSlivers(context);
    final AxisDirection axisDirection = _getDirection(context);
    final scrollPhysics =
        widget.physics ?? const AlwaysScrollableScrollPhysics();
    return Scrollable(
      axisDirection: axisDirection,
      controller: _effectiveController,
      physics: scrollPhysics,
      viewportBuilder: (BuildContext context, ViewportOffset offset) {
        return Viewport(
          axisDirection: axisDirection,
          anchor: widget.anchor,
          offset: offset,
          center: positiveListKey,
          slivers: slivers,
          cacheExtent: widget.cacheExtent,
        );
      },
    );
  }

  AxisDirection _getDirection(BuildContext context) {
    return getAxisDirectionFromAxisReverseAndDirectionality(
        context, widget.scrollDirection, widget.reverse);
  }

  List<Widget> _buildSlivers(BuildContext context) {
    return <Widget>[
      SliverList(
        delegate: negativeChildrenDelegate,
      ),
      SliverList(
        delegate: positiveChildrenDelegate,
        key: positiveListKey,
      ),
    ];
  }

  SliverChildDelegate get positiveChildrenDelegate {
    final itemCount = widget.itemCount;
    return SliverChildBuilderDelegate(
      (context, index) {
        return widget.itemBuilder(context, index % widget.contentCount, index);
      },
      childCount: itemCount,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
    );
  }

  SliverChildDelegate get negativeChildrenDelegate {
    final itemCount = widget.itemCount;
    return SliverChildBuilderDelegate(
      (context, index) {
        if (index == 0) return const SizedBox.shrink();
        return widget.itemBuilder(
            context, -index % widget.contentCount, -index);
      },
      childCount: itemCount,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(EnumProperty<Axis>('scrollDirection', widget.scrollDirection));
    properties.add(FlagProperty('reverse',
        value: widget.reverse, ifTrue: 'reversed', showName: true));
    properties.add(DiagnosticsProperty<ScrollController>(
        'controller', widget.controller,
        showName: false, defaultValue: null));
    properties.add(DiagnosticsProperty<ScrollPhysics>('physics', widget.physics,
        showName: false, defaultValue: null));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>(
        'padding', widget.padding,
        defaultValue: null));
    properties.add(
        DoubleProperty('cacheExtent', widget.cacheExtent, defaultValue: null));
  }
}

/// [ScrollController] と同じですが、無限の境界を持つ [ScrollPosition] オブジェクトを提供します。
class CycledScrollController extends ScrollController {
  /// 新しい [CycledScrollController] を作成します。
  CycledScrollController({
    double initialScrollOffset = 0.0,
    bool keepScrollOffset = true,
    String? debugLabel,
  }) : super(
          initialScrollOffset: initialScrollOffset,
          keepScrollOffset: keepScrollOffset,
          debugLabel: debugLabel,
        );

  ScrollDirection get currentScrollDirection => position.userScrollDirection;

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics,
      ScrollContext context, ScrollPosition? oldPosition) {
    return _InfiniteScrollPosition(
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }
}

class _InfiniteScrollPosition extends ScrollPositionWithSingleContext {
  _InfiniteScrollPosition({
    required ScrollPhysics physics,
    required ScrollContext context,
    double? initialPixels = 0.0,
    bool keepScrollOffset = true,
    ScrollPosition? oldPosition,
    String? debugLabel,
  }) : super(
          physics: physics,
          context: context,
          initialPixels: initialPixels,
          keepScrollOffset: keepScrollOffset,
          oldPosition: oldPosition,
          debugLabel: debugLabel,
        );

  @override
  double get minScrollExtent => double.negativeInfinity;

  @override
  double get maxScrollExtent => double.infinity;
}
