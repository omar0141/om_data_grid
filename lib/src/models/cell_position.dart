class CellPosition {
  final int rowIndex;
  final int columnIndex;

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
