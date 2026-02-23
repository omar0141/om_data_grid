/// Represents the position of a cell within the grid.
class CellPosition {
  /// The row index of the cell.
  final int rowIndex;

  /// The column index of the cell.
  final int columnIndex;

  /// Creates a [CellPosition].
  const CellPosition({required this.rowIndex, required this.columnIndex});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellPosition &&
          runtimeType == other.runtimeType &&
          rowIndex == other.rowIndex &&
          columnIndex == other.columnIndex;

  @override
  int get hashCode => rowIndex.hashCode ^ columnIndex.hashCode;

  /// Checks if this position is within a rectangular range defined by [start] and [end].
  bool isWithin(CellPosition start, CellPosition end) {
    final minRow = start.rowIndex < end.rowIndex
        ? start.rowIndex
        : end.rowIndex;
    final maxRow = start.rowIndex > end.rowIndex
        ? start.rowIndex
        : end.rowIndex;
    final minCol = start.columnIndex < end.columnIndex
        ? start.columnIndex
        : end.columnIndex;
    final maxCol = start.columnIndex > end.columnIndex
        ? start.columnIndex
        : end.columnIndex;

    return rowIndex >= minRow &&
        rowIndex <= maxRow &&
        columnIndex >= minCol &&
        columnIndex <= maxCol;
  }
}
