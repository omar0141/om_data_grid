/// Defines the type of aggregation to perform on a column's data.
enum OmAggregationType {
  /// No aggregation.
  none,

  /// Count the number of items.
  count,

  /// Calculate the sum of numerical values.
  sum,

  /// Calculate the average of numerical values.
  avg,

  /// Find the minimum value.
  min,

  /// Find the maximum value.
  max,

  /// Use the first value.
  first,

  /// Use the last value.
  last,
}
