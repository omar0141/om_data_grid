import 'package:om_data_grid/src/models/grid_column_model.dart';
import 'package:flutter/material.dart';

/// Represents an instance of a chart within the grid.
class OmChartInstance {
  /// Unique identifier for the chart.
  final String id;

  /// Data used to populate the chart.
  final List<Map<String, dynamic>> data;

  /// Columns used in the chart configuration.
  final List<OmGridColumnModel> columns;

  /// Initial position of the chart on screen.
  final Offset initialPosition;

  /// Creates a [OmChartInstance].
  OmChartInstance({
    required this.id,
    required this.data,
    required this.columns,
    this.initialPosition = const Offset(100, 100),
  });
}
