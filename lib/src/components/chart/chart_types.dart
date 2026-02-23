enum ChartType {
  column,
  stackedColumn,
  bar,
  stackedBar,
  line,
  area,
  pie,
  doughnut,
  scatter,
  spline,
  stepline,
  funnel,
  pyramid,
  radialBar,
  histogram,
}

class ChartSampleData {
  final String x;
  final double y;
  ChartSampleData({required this.x, required this.y});
}
