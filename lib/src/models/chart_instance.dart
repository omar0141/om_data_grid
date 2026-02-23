import 'package:om_data_grid/src/models/grid_column_model.dart';
import 'package:flutter/material.dart';

class ChartInstance {
  final String id;
  final List<Map<String, dynamic>> data;
  final List<GridColumnModel> columns;
  final Offset initialPosition;

  ChartInstance({
    required this.id,
    required this.data,
    required this.columns,
    this.initialPosition = const Offset(100, 100),
  });
}
