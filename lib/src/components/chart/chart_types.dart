enum OmChartType {
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

class OmChartSampleData {
  final String x;
  final double y;
  OmChartSampleData({required this.x, required this.y});
}
