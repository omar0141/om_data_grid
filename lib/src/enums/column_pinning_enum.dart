/// Defines the pinning behavior of a column.
enum ColumnPinning {
  /// The column is not pinned and scrolls normally.
  none,

  /// The column is pinned to the left side of the grid.
  left,

  /// The column is pinned to the right side of the grid.
  right,
}
