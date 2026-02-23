import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'chart_types.dart';

class ChartRenderer extends StatelessWidget {
  final ChartType selectedChartType;
  final List<Map<String, dynamic>> rawData;
  final String title;
  final bool showLegend;
  final bool showDataLabels;
  final bool showTooltip;
  final bool isTransposed;
  final String xAxisKey;
  final List<String> yAxisKeys;
  final Map<String, String> columnTitles;
  final GlobalKey<SfCartesianChartState> cartesianChartKey;
  final GlobalKey<SfCircularChartState> circularChartKey;
  final GlobalKey<SfFunnelChartState> funnelChartKey;
  final GlobalKey<SfPyramidChartState> pyramidChartKey;

  const ChartRenderer({
    super.key,
    required this.selectedChartType,
    required this.rawData,
    required this.title,
    required this.showLegend,
    required this.showDataLabels,
    required this.showTooltip,
    required this.isTransposed,
    required this.xAxisKey,
    required this.yAxisKeys,
    required this.columnTitles,
    required this.cartesianChartKey,
    required this.circularChartKey,
    required this.funnelChartKey,
    required this.pyramidChartKey,
  });

  List<Map<String, dynamic>> _getGroupedData(List<Map<String, dynamic>> data) {
    if (xAxisKey.isEmpty) return data;

    final Map<String, Map<String, dynamic>> grouped = {};

    for (var row in data) {
      final xVal = row[xAxisKey]?.toString() ?? '';
      if (!grouped.containsKey(xVal)) {
        grouped[xVal] = {xAxisKey: row[xAxisKey]};
        for (var yKey in yAxisKeys) {
          grouped[xVal]![yKey] = 0.0;
        }
      }

      for (var yKey in yAxisKeys) {
        final val = row[yKey];
        final double numericVal = val is num
            ? val.toDouble()
            : (double.tryParse(val?.toString() ?? '0') ?? 0.0);
        grouped[xVal]![yKey] = (grouped[xVal]![yKey] as double) + numericVal;
      }
    }

    return grouped.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final tooltipBehavior = TooltipBehavior(
      enable: showTooltip,
      shared: true,
      activationMode: ActivationMode.singleTap,
    );
    final legend = Legend(
      isVisible: showLegend,
      position: LegendPosition.bottom,
      overflowMode: LegendItemOverflowMode.wrap,
    );
    final dataLabelSettings = DataLabelSettings(isVisible: showDataLabels);
    final chartTitle = ChartTitle(
      text: title,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );

    final List<Map<String, dynamic>> groupedData = _getGroupedData(rawData);

    // Prepare data for non-cartesian charts (take only the first Y key)
    final String firstYKey = yAxisKeys.isNotEmpty ? yAxisKeys.last : '';
    final List<ChartSampleData> simpleChartData = groupedData.map((row) {
      final xVal = row[xAxisKey]?.toString() ?? '';
      final yVal = row[firstYKey];
      return ChartSampleData(
        x: xVal,
        y: yVal is num
            ? yVal.toDouble()
            : (double.tryParse(yVal?.toString() ?? '0') ?? 0.0),
      );
    }).toList();

    switch (selectedChartType) {
      case ChartType.funnel:
        return SfFunnelChart(
          key: funnelChartKey,
          title: chartTitle,
          legend: legend,
          tooltipBehavior: tooltipBehavior,
          series: FunnelSeries<ChartSampleData, String>(
            dataSource: simpleChartData,
            xValueMapper: (d, _) => d.x,
            yValueMapper: (d, _) => d.y,
            dataLabelSettings: dataLabelSettings,
          ),
        );
      case ChartType.pyramid:
        return SfPyramidChart(
          key: pyramidChartKey,
          title: chartTitle,
          legend: legend,
          tooltipBehavior: tooltipBehavior,
          series: PyramidSeries<ChartSampleData, String>(
            dataSource: simpleChartData,
            xValueMapper: (d, _) => d.x,
            yValueMapper: (d, _) => d.y,
            dataLabelSettings: dataLabelSettings,
          ),
        );
      case ChartType.radialBar:
        return SfCircularChart(
          key: circularChartKey,
          title: chartTitle,
          legend: legend,
          tooltipBehavior: tooltipBehavior,
          series: <CircularSeries<ChartSampleData, String>>[
            RadialBarSeries<ChartSampleData, String>(
              dataSource: simpleChartData,
              xValueMapper: (d, _) => d.x,
              yValueMapper: (d, _) => d.y,
              dataLabelSettings: dataLabelSettings,
            ),
          ],
        );
      case ChartType.histogram:
        return SfCartesianChart(
          key: cartesianChartKey,
          title: chartTitle,
          legend: legend,
          tooltipBehavior: tooltipBehavior,
          primaryXAxis: const NumericAxis(),
          series: <HistogramSeries<Map<String, dynamic>, double>>[
            HistogramSeries<Map<String, dynamic>, double>(
              dataSource: rawData,
              yValueMapper: (d, _) {
                final val = d[firstYKey];
                return val is num
                    ? val.toDouble()
                    : (double.tryParse(val?.toString() ?? '0') ?? 0.0);
              },
              dataLabelSettings: dataLabelSettings,
            ),
          ],
        );
      case ChartType.pie:
      case ChartType.doughnut:
        return SfCircularChart(
          key: circularChartKey,
          title: chartTitle,
          legend: legend,
          tooltipBehavior: tooltipBehavior,
          series: <CircularSeries<ChartSampleData, String>>[
            if (selectedChartType == ChartType.pie)
              PieSeries<ChartSampleData, String>(
                dataSource: simpleChartData,
                xValueMapper: (d, _) => d.x,
                yValueMapper: (d, _) => d.y,
                dataLabelSettings: dataLabelSettings,
              )
            else
              DoughnutSeries<ChartSampleData, String>(
                dataSource: simpleChartData,
                innerRadius: '60%',
                xValueMapper: (d, _) => d.x,
                yValueMapper: (d, _) => d.y,
                dataLabelSettings: dataLabelSettings,
              ),
          ],
        );
      default:
        return SfCartesianChart(
          key: cartesianChartKey,
          title: chartTitle,
          legend: legend,
          isTransposed: isTransposed,
          tooltipBehavior: tooltipBehavior,
          primaryXAxis: CategoryAxis(
            title: AxisTitle(text: columnTitles[xAxisKey] ?? xAxisKey),
            labelRotation: 45,
          ),
          primaryYAxis: NumericAxis(
            title: AxisTitle(
              text: yAxisKeys.length == 1
                  ? (columnTitles[firstYKey] ?? firstYKey)
                  : 'Values',
            ),
          ),
          series: _getMultiSeries(dataLabelSettings, groupedData),
        );
    }
  }

  List<CartesianSeries<Map<String, dynamic>, String>> _getMultiSeries(
    DataLabelSettings dls,
    List<Map<String, dynamic>> groupedData,
  ) {
    return yAxisKeys.map((yKey) {
      final String seriesName = columnTitles[yKey] ?? yKey;

      switch (selectedChartType) {
        case ChartType.line:
          return LineSeries<Map<String, dynamic>, String>(
            name: seriesName,
            dataSource: groupedData,
            xValueMapper: (d, _) => d[xAxisKey]?.toString() ?? '',
            yValueMapper: (d, _) {
              final val = d[yKey];
              return val is num
                  ? val.toDouble()
                  : (double.tryParse(val?.toString() ?? '0') ?? 0.0);
            },
            dataLabelSettings: dls,
            markerSettings: const MarkerSettings(isVisible: true),
          );
        case ChartType.bar:
          return BarSeries<Map<String, dynamic>, String>(
            name: seriesName,
            dataSource: groupedData,
            xValueMapper: (d, _) => d[xAxisKey]?.toString() ?? '',
            yValueMapper: (d, _) {
              final val = d[yKey];
              return val is num
                  ? val.toDouble()
                  : (double.tryParse(val?.toString() ?? '0') ?? 0.0);
            },
            dataLabelSettings: dls,
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(4),
            ),
          );
        case ChartType.column:
          return ColumnSeries<Map<String, dynamic>, String>(
            name: seriesName,
            dataSource: groupedData,
            xValueMapper: (d, _) => d[xAxisKey]?.toString() ?? '',
            yValueMapper: (d, _) {
              final val = d[yKey];
              return val is num
                  ? val.toDouble()
                  : (double.tryParse(val?.toString() ?? '0') ?? 0.0);
            },
            dataLabelSettings: dls,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          );
        case ChartType.area:
          return AreaSeries<Map<String, dynamic>, String>(
            name: seriesName,
            dataSource: groupedData,
            xValueMapper: (d, _) => d[xAxisKey]?.toString() ?? '',
            yValueMapper: (d, _) {
              final val = d[yKey];
              return val is num
                  ? val.toDouble()
                  : (double.tryParse(val?.toString() ?? '0') ?? 0.0);
            },
            dataLabelSettings: dls,
          );
        case ChartType.stackedBar:
          return StackedBarSeries<Map<String, dynamic>, String>(
            name: seriesName,
            dataSource: groupedData,
            xValueMapper: (d, _) => d[xAxisKey]?.toString() ?? '',
            yValueMapper: (d, _) {
              final val = d[yKey];
              return val is num
                  ? val.toDouble()
                  : (double.tryParse(val?.toString() ?? '0') ?? 0.0);
            },
            dataLabelSettings: dls,
          );
        case ChartType.stackedColumn:
          return StackedColumnSeries<Map<String, dynamic>, String>(
            name: seriesName,
            dataSource: groupedData,
            xValueMapper: (d, _) => d[xAxisKey]?.toString() ?? '',
            yValueMapper: (d, _) {
              final val = d[yKey];
              return val is num
                  ? val.toDouble()
                  : (double.tryParse(val?.toString() ?? '0') ?? 0.0);
            },
            dataLabelSettings: dls,
          );
        case ChartType.scatter:
          return ScatterSeries<Map<String, dynamic>, String>(
            name: seriesName,
            dataSource: groupedData,
            xValueMapper: (d, _) => d[xAxisKey]?.toString() ?? '',
            yValueMapper: (d, _) {
              final val = d[yKey];
              return val is num
                  ? val.toDouble()
                  : (double.tryParse(val?.toString() ?? '0') ?? 0.0);
            },
            dataLabelSettings: dls,
          );
        case ChartType.spline:
          return SplineSeries<Map<String, dynamic>, String>(
            name: seriesName,
            dataSource: groupedData,
            xValueMapper: (d, _) => d[xAxisKey]?.toString() ?? '',
            yValueMapper: (d, _) {
              final val = d[yKey];
              return val is num
                  ? val.toDouble()
                  : (double.tryParse(val?.toString() ?? '0') ?? 0.0);
            },
            dataLabelSettings: dls,
          );
        case ChartType.stepline:
          return StepLineSeries<Map<String, dynamic>, String>(
            name: seriesName,
            dataSource: groupedData,
            xValueMapper: (d, _) => d[xAxisKey]?.toString() ?? '',
            yValueMapper: (d, _) {
              final val = d[yKey];
              return val is num
                  ? val.toDouble()
                  : (double.tryParse(val?.toString() ?? '0') ?? 0.0);
            },
            dataLabelSettings: dls,
          );
        default:
          return LineSeries<Map<String, dynamic>, String>(
            name: seriesName,
            dataSource: groupedData,
            xValueMapper: (d, _) => d[xAxisKey]?.toString() ?? '',
            yValueMapper: (d, _) {
              final val = d[yKey];
              return val is num
                  ? val.toDouble()
                  : (double.tryParse(val?.toString() ?? '0') ?? 0.0);
            },
          );
      }
    }).toList();
  }
}
