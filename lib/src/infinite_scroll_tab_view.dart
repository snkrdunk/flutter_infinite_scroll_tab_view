import 'package:flutter/material.dart';

import 'inner_infinite_scroll_tab_view.dart';

/// 指定されたインデックスで [Widget] を構築するためのコールバックの型。
typedef SelectIndexedWidgetBuilder = Widget Function(
    BuildContext context, int index, bool isSelected);

/// 指定されたインデックスで [Text] Widget を構築するためのコールバックの型。
typedef SelectIndexedTextBuilder = Text Function(int index, bool isSelected);

/// タップされたタブで処理を実行するためのコールバックの型。
typedef IndexedTapCallback = void Function(int index);

/// タブとページの組み合わせを表示するためのウィジェット。
///
/// 内部的には、タブとページは `ListView` のような単なるスクロール可能な要素として構築されます。
/// しかし、これらは [double.negativeInfinity] から [double.infinity] までの広大なインデックス範囲を持っているため、
/// 無限にスクロールできます。
class InfiniteScrollTabView extends StatelessWidget {
  /// 無限にスクロールできるタブビューウィジェットを作成します。
  const InfiniteScrollTabView({
    Key? key,
    required this.contentLength,
    required this.tabBuilder,
    this.stackedContentOnTabBuilder,
    required this.pageBuilder,
    this.onTabTap,
    this.separator,
    this.backgroundColor,
    this.onPageChanged,
    this.indicatorColor = Colors.pinkAccent,
    this.indicatorHeight,
    this.tabHeight = 44.0,
    this.tabHorizontalPadding = 12.0,
    this.tabTopPadding = 0,
    this.tabBottomPadding = 0,
    this.size,
    this.forceFixedTabWidth = false,
    this.fixedTabWidthFraction = 0.5,
    this.physics = const PageScrollPhysics(),
    this.cacheExtent,
  }) : super(key: key);

  /// タブとページの長さ。
  ///
  /// この値はタブとページで共有されるため、同じコンテンツ長である必要があります。
  ///
  /// そうでない場合、この値がタブのコンテンツより小さい場合、[tabBuilder] の出力は
  /// [contentLength] 内で繰り返されます。
  final int contentLength;

  /// 無限にスクロールできるタブコンテンツを構築するためのコールバック。
  ///
  /// 型によって指定された [Text] Widget を返す必要があります。
  ///
  /// 参照: [SelectIndexedTextBuilder]
  /// `index` は実際のインデックスを [contentLength] で割った余りです。
  /// `isSelected` はタブが選択されているかどうかを示す状態です。
  final SelectIndexedTextBuilder tabBuilder;

  /// [tabBuilder] で表示されるタブラベルに [Stack] で重ねて表示するウィジェット。
  ///
  /// 典型的には [Positioned] を使って、タブの上にバッジを表示するなどの目的で使用する。
  final SelectIndexedWidgetBuilder? stackedContentOnTabBuilder;

  /// 無限にスクロールできるページコンテンツを構築するためのコールバック。
  ///
  /// 参照: [SelectIndexedWidgetBuilder]
  /// `index` は実際のインデックスを [contentLength] で割った余りです。
  /// `isSelected` はページが選択されているかどうかを示す状態です。
  final SelectIndexedWidgetBuilder pageBuilder;

  /// タップされたタブ要素のコールバック。
  ///
  /// `index` は実際のインデックスを [contentLength] で割った余りです。
  final IndexedTapCallback? onTabTap;

  /// タブとページの間に表示される境界線の仕様。
  ///
  /// これが null の場合、境界線は表示されません。
  final BorderSide? separator;

  /// タブリストの色。
  ///
  /// これが null の場合、リストの背景色は [Material] のデフォルトになります。
  final Color? backgroundColor;

  /// 選択されたページが変更されたときのコールバック。
  ///
  /// これは、タブのタップとページのスワイプの両方で呼び出されます。
  final ValueChanged<int>? onPageChanged;

  /// 選択されたページを示すインジケータの色。
  ///
  /// デフォルトは [Colors.pinkAccent] で、null であってはなりません。
  final Color indicatorColor;

  /// インジケータの高さ。
  ///
  /// これが null の場合、インジケータの高さは [separator] の高さに合わせられます。
  /// それも null の場合は 2.0 にフォールバックします。
  ///
  /// これは 1.0 以上である必要があります。
  final double? indicatorHeight;

  /// タブコンテンツの高さ。
  ///
  /// デフォルトは 44.0 です。
  final double tabHeight;

  /// タブラベルの左右方向の余白。
  ///
  /// デフォルトでは `12.0` が設定されている。
  ///
  /// [tabBuilder] で与えた [Text] ウィジェットの左右側に設定され、
  /// [InnerInfiniteScrollTabView] の中では水平方向のタブ移動の移動量の計算にも使用されて
  /// いる。
  final double tabHorizontalPadding;

  /// タブラベルの上方向の余白。
  ///
  /// デフォルトでは `0` が設定されている。
  ///
  /// [tabHeight] の中で [tabTopPadding] に設定した大きさの余白が、[tabBuilder] で与えた
  /// [Text] ウィジェットの上側に設定される。
  final double tabTopPadding;

  /// タブラベルの下方向の余白。
  ///
  /// デフォルトでは `0` が設定されている。
  ///
  /// [tabHeight] の中で [tabTopPadding] に設定した大きさの余白が、[tabBuilder] で与えた
  /// [Text] ウィジェットの下側に設定される。
  final double tabBottomPadding;

  /// このウィジェットのサイズ制約。
  ///
  /// これが null の場合、デフォルトで `MediaQuery.of(context).size` が使用されます。
  /// この値は、テストなどのまれな場合にのみ指定する必要があります。
  /// 内部的には、これはページの幅を取得するためにのみ使用されますが、この値は
  /// ウィジェット全体の幅を決定します。
  final Size? size;

  /// 固定タブ幅を使用するかどうかのフラグ。
  ///
  /// これを有効にすると、タブのサイズは [size] と [fixedTabWidthFraction] から計算された
  /// 固定サイズに揃えられます。
  ///
  /// タブのコンテンツ幅が固定幅を超える場合、コンテンツは [FittedBox] と
  /// [BoxFit.contain] によってサイズ変更されます。
  final bool forceFixedTabWidth;

  /// 固定タブサイズが使用される場合の割合の値。
  ///
  /// デフォルトは 0.5 です。
  /// [forceFixedTabWidth] が false の場合、これは無視されます。
  final double fixedTabWidthFraction;

  final ScrollPhysics physics;
  
  /// キャッシュ目的で適用されたスクロールオフセットに対するスクロール可能軸のビューポートの範囲。
  ///
  /// これにより、表示領域から遠く離れた要素の再構築を防ぐことでパフォーマンスが向上します。
  final double? cacheExtent;

  @override
  Widget build(BuildContext context) {
    if (indicatorHeight != null) {
      assert(indicatorHeight! >= 1.0);
    }

    return InnerInfiniteScrollTabView(
      size: MediaQuery.of(context).size,
      contentLength: contentLength,
      tabBuilder: tabBuilder,
      stackedContentOnTabBuilder: stackedContentOnTabBuilder,
      pageBuilder: pageBuilder,
      onTabTap: onTabTap,
      separator: separator,
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
      defaultTextStyle: DefaultTextStyle.of(context).style,
      textDirection: Directionality.of(context),
      backgroundColor: backgroundColor,
      onPageChanged: onPageChanged,
      indicatorColor: indicatorColor,
      indicatorHeight: indicatorHeight,
      defaultLocale: Localizations.localeOf(context),
      tabHeight: tabHeight,
      tabHorizontalPadding: tabHorizontalPadding,
      tabTopPadding: tabTopPadding,
      tabBottomPadding: tabBottomPadding,
      forceFixedTabWidth: forceFixedTabWidth,
      fixedTabWidthFraction: fixedTabWidthFraction,
      physics: physics,
      cacheExtent: cacheExtent,
    );
  }
}
