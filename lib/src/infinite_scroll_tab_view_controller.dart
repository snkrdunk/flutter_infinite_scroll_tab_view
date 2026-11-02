import 'infinite_scroll_tab_view.dart';
import 'inner_infinite_scroll_tab_view.dart';

/// [InfiniteScrollTabView] の選択タブをウィジェットの外から操作するためのコントローラー。
///
/// Deep Link などでタブをタップせずに特定のタブへ移動したい場合に使用する。
///
/// ```dart
/// final controller = InfiniteScrollTabViewController();
///
/// InfiniteScrollTabView(
///   controller: controller,
///   contentLength: tabs.length,
///   ...
/// );
///
/// // 3番目のタブへ移動する
/// controller.animateToIndex(2);
/// ```
///
/// 1つの [InfiniteScrollTabView] にのみ渡すこと。複数のウィジェットに渡した場合は、
/// 最後に接続されたウィジェットだけが操作対象になる。
class InfiniteScrollTabViewController {
  InnerInfiniteScrollTabViewState? _state;

  /// ウィジェットに接続されているかどうか。
  bool get isAttached => _state != null;

  /// 選択中のタブのインデックス。
  ///
  /// 接続されていない場合は `null` を返す。
  int? get selectedIndex => _state?.selectedIndex;

  /// アニメーションしながら [index] のタブへ移動する。
  ///
  /// 接続されていない場合、または [index] が範囲外の場合は何もしない。
  Future<void> animateToIndex(int index) async {
    await _state?.moveToIndex(index, animate: true);
  }

  /// アニメーションせずに [index] のタブへ移動する。
  ///
  /// 接続されていない場合、または [index] が範囲外の場合は何もしない。
  Future<void> jumpToIndex(int index) async {
    await _state?.moveToIndex(index, animate: false);
  }

  /// [InnerInfiniteScrollTabView] から接続するために呼ばれる。
  ///
  /// パッケージの利用者が直接呼ぶ必要はない。
  void attach(InnerInfiniteScrollTabViewState state) {
    _state = state;
  }

  /// [InnerInfiniteScrollTabView] から切断するために呼ばれる。
  ///
  /// パッケージの利用者が直接呼ぶ必要はない。
  void detach(InnerInfiniteScrollTabViewState state) {
    if (identical(_state, state)) {
      _state = null;
    }
  }
}
