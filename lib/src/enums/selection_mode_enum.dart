/// Defines the selection mode for the grid.
enum SelectionMode {
  /// Selection is disabled.
  none,

  /// Only a single row can be selected at a time.
  single,

  /// Multiple rows can be selected.
  multiple,

  /// Single cell selection (may not be fully supported in all contexts).
  cell,
}
