/// Defines the pinning behavior of a column.
enum OmColumnPinning {
  /// The column is not pinned and scrolls normally.
  none,

  /// The column is pinned to the start side of the grid.
  start,

  /// The column is pinned to the end side of the grid.
  end,
}
