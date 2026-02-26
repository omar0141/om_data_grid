import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:om_data_grid/src/utils/general_helpers.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/grid_column_model.dart';
import '../models/datagrid_configuration.dart';
import 'chart/chart_types.dart';
import 'chart/chart_renderer.dart';
import 'chart/chart_settings_sidebar.dart';
import 'chart/chart_export_handler.dart';

class OmChartPopup extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final List<OmGridColumnModel> columns;
  final VoidCallback onClose;
  final OmDataGridConfiguration configuration;
  final VoidCallback? onBringToFront;
  final Offset initialPosition;

  const OmChartPopup({
    super.key,
    required this.data,
    required this.columns,
    required this.onClose,
    required this.configuration,
    this.initialPosition = const Offset(100, 100),
    this.onBringToFront,
  });

  @override
  State<OmChartPopup> createState() => _ChartPopupState();
}

class _ChartPopupState extends State<OmChartPopup> {
  late Offset _position;
  double _width = 850;
  double _height = 600;
  bool _isFullScreen = false;
  OmChartType _selectedChartType = OmChartType.column;
  late String _xAxisColumn;
  late List<String> _yAxisColumns;

  // Persistent state
  late final TextEditingController _titleController;
  bool _showLegend = true;
  bool _showDataLabels = true;
  bool _showTooltip = true;
  bool _isTransposed = false;
  int _activeTab = 0;
  bool _isExporting = false;

  // Global Keys for charts to capture images
  GlobalKey<SfCartesianChartState> _cartesianChartKey = GlobalKey();
  GlobalKey<SfCircularChartState> _circularChartKey = GlobalKey();
  GlobalKey<SfFunnelChartState> _funnelChartKey = GlobalKey();
  GlobalKey<SfPyramidChartState> _pyramidChartKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      if (size.width < 600) {
        setState(() {
          _isFullScreen = true;
          _width = size.width;
          _height = size.height;
        });
      }
    });

    _position = widget.initialPosition;
    _titleController = TextEditingController(
        text: widget.configuration.labels.dataAnalysisTitle);

    // Filter columns that can be shown in charts
    final visibleChartColumns =
        widget.columns.where((c) => c.showInChart).toList();

    // Initialize X-Axis
    final xAxisOptions =
        visibleChartColumns.where((c) => c.canBeXAxis).toList();
    if (xAxisOptions.isNotEmpty) {
      _xAxisColumn = xAxisOptions.first.column.key;
    } else {
      _xAxisColumn = widget.columns.first.column.key; // Fallback
    }

    // Find all numeric columns to initialize _yAxisColumns among those allowed
    final List<String> numericKeys = visibleChartColumns
        .where((col) {
          if (!col.canBeYAxis) return false;
          if (widget.data.isEmpty) return false;
          final val = widget.data[0][col.column.key];
          return val is num || (val is String && double.tryParse(val) != null);
        })
        .map((c) => c.column.key)
        .toList();

    if (numericKeys.isNotEmpty) {
      // Select all numeric columns by default
      _yAxisColumns = List.from(numericKeys);
    } else {
      final yAxisOptions =
          visibleChartColumns.where((c) => c.canBeYAxis).toList();
      if (yAxisOptions.isNotEmpty) {
        _yAxisColumns = [yAxisOptions.first.column.key];
      } else {
        _yAxisColumns = [widget.columns.first.column.key];
      }
    }

    // Try to ensure X-axis is not one of the Y-axes if possible
    if (_yAxisColumns.contains(_xAxisColumn) && xAxisOptions.length > 1) {
      try {
        _xAxisColumn = xAxisOptions
            .firstWhere((c) => !_yAxisColumns.contains(c.column.key))
            .column
            .key;
      } catch (_) {
        // Fallback to current if no other options
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<Uint8List?> _captureChartImage() async {
    try {
      ui.Image? image;
      if (_selectedChartType == OmChartType.funnel) {
        image = await _funnelChartKey.currentState?.toImage(pixelRatio: 2.0);
      } else if (_selectedChartType == OmChartType.pyramid) {
        image = await _pyramidChartKey.currentState?.toImage(pixelRatio: 2.0);
      } else if (_selectedChartType == OmChartType.pie ||
          _selectedChartType == OmChartType.doughnut ||
          _selectedChartType == OmChartType.radialBar) {
        image = await _circularChartKey.currentState?.toImage(pixelRatio: 2.0);
      } else {
        image = await _cartesianChartKey.currentState?.toImage(pixelRatio: 2.0);
      }

      if (image == null) return null;
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing chart image: $e');
      return null;
    }
  }

  Future<void> _exportToPDF() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      final bytes = await _captureChartImage();
      if (bytes == null) {
        throw Exception('Failed to capture chart image');
      }
      await OmChartExportHandler.exportToPDF(
        chartImageBytes: bytes,
        title: _titleController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(widget.configuration.labels.successfullyExportedToPdf)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${widget.configuration.labels.errorExportingPdf}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportToExcel() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      final bytes = await _captureChartImage();
      await OmChartExportHandler.exportToExcel(
        data: widget.data,
        xAxisColumn: _xAxisColumn,
        yAxisColumns: _yAxisColumns,
        chartType: _selectedChartType,
        chartImageBytes: bytes,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  widget.configuration.labels.successfullyExportedToExcel)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${widget.configuration.labels.errorExportingExcel}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final bool isMobile = screenSize.width < 600;

    return PositionedDirectional(
      start: (_isFullScreen || isMobile) ? 0 : _position.dx,
      top: (_isFullScreen || isMobile) ? 0 : _position.dy,
      bottom: (_isFullScreen || isMobile) ? 0 : null,
      end: (_isFullScreen || isMobile) ? 0 : null,
      width: (_isFullScreen || isMobile) ? null : _width,
      height: (_isFullScreen || isMobile) ? null : _height,
      child: GestureDetector(
        onTapDown: (_) => widget.onBringToFront?.call(),
        child: Material(
          elevation: _isFullScreen ? 0 : 12,
          borderRadius:
              _isFullScreen ? BorderRadius.zero : BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: BoxDecoration(
              color: widget.configuration.chartPopupBackgroundColor!,
              border: _isFullScreen
                  ? null
                  : Border.all(
                      color: widget.configuration.chartPopupBorderColor!,
                      width: 0.5,
                    ),
            ),
            child: Stack(
              children: [
                _buildContent(fullScreen: _isFullScreen),
                if (!_isFullScreen && !isMobile) _buildResizeHandle(),
                if (_isExporting) _buildLoadingOverlay(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: widget.configuration.chartPopupLoadingBackgroundColor!
          .withOpacityNew(0.3),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: widget.configuration.chartPopupBackgroundColor!,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.configuration.chartPopupLoadingBackgroundColor!
                    .withOpacityNew(0.2),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.configuration.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.configuration.labels.generatingExport,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: widget.configuration.chartPopupLoadingTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResizeHandle() {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return PositionedDirectional(
      end: 0,
      bottom: 0,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final dx = isRTL ? -details.delta.dx : details.delta.dx;
            _width = (_width + dx).clamp(450.0, 1600.0);
            _height = (_height + details.delta.dy).clamp(350.0, 1000.0);
          });
        },
        child: MouseRegion(
          cursor: isRTL
              ? SystemMouseCursors.resizeUpRightDownLeft
              : SystemMouseCursors.resizeUpLeftDownRight,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Icon(
              isRTL ? Icons.south_west : Icons.south_east,
              size: 18,
              color: widget.configuration.chartPopupResizeHandleColor!,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent({required bool fullScreen}) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return Column(
      children: [
        _buildHeader(fullScreen: fullScreen, isMobile: isMobile),
        Expanded(
          child: isMobile
              ? _buildMobileContent()
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OmChartSettingsSidebar(
                      activeTab: _activeTab,
                      selectedChartType: _selectedChartType,
                      xAxisColumn: _xAxisColumn,
                      yAxisColumns: _yAxisColumns,
                      columns: widget.columns,
                      configuration: widget.configuration,
                      titleController: _titleController,
                      showLegend: _showLegend,
                      showDataLabels: _showDataLabels,
                      showTooltip: _showTooltip,
                      isTransposed: _isTransposed,
                      onTabChanged: (i) => setState(() => _activeTab = i),
                      onChartTypeChanged: (t) => setState(() {
                        _selectedChartType = t;
                        _cartesianChartKey = GlobalKey();
                        _circularChartKey = GlobalKey();
                        _funnelChartKey = GlobalKey();
                        _pyramidChartKey = GlobalKey();
                      }),
                      onXAxisChanged: (v) => setState(() => _xAxisColumn = v),
                      onYAxisChanged: (v) => setState(() {
                        _yAxisColumns = v;
                        _cartesianChartKey = GlobalKey();
                        _circularChartKey = GlobalKey();
                        _funnelChartKey = GlobalKey();
                        _pyramidChartKey = GlobalKey();
                      }),
                      onShowLegendChanged: (v) =>
                          setState(() => _showLegend = v),
                      onShowDataLabelsChanged: (v) =>
                          setState(() => _showDataLabels = v),
                      onShowTooltipChanged: (v) =>
                          setState(() => _showTooltip = v),
                      onIsTransposedChanged: (v) =>
                          setState(() => _isTransposed = v),
                      onTitleChanged: () => setState(() {}),
                      onExportPDF: _exportToPDF,
                      onExportExcel: _exportToExcel,
                    ),
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: widget.configuration.gridBorderColor,
                    ),
                    Expanded(
                      child: RepaintBoundary(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          color:
                              widget.configuration.chartPopupBackgroundColor!,
                          child: _buildChartRenderer(),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildMobileContent() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: widget.configuration.chartPopupBackgroundColor!,
      child: _buildChartRenderer(),
    );
  }

  void _showMobileSettings(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: widget.configuration.mobileSettingsBackgroundColor!,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.configuration.labels.settings,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.configuration.mobileSettingsHeaderColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: widget.configuration.mobileSettingsIconColor,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StatefulBuilder(
                builder: (context, setModalState) {
                  return OmChartSettingsSidebar(
                    isMobile: true,
                    activeTab: index,
                    selectedChartType: _selectedChartType,
                    xAxisColumn: _xAxisColumn,
                    yAxisColumns: _yAxisColumns,
                    columns: widget.columns,
                    configuration: widget.configuration,
                    titleController: _titleController,
                    showLegend: _showLegend,
                    showDataLabels: _showDataLabels,
                    showTooltip: _showTooltip,
                    isTransposed: _isTransposed,
                    onTabChanged: (i) {
                      setState(() => _activeTab = i);
                      setModalState(() {});
                    },
                    onChartTypeChanged: (t) {
                      setState(() {
                        _selectedChartType = t;
                        _cartesianChartKey = GlobalKey();
                        _circularChartKey = GlobalKey();
                        _funnelChartKey = GlobalKey();
                        _pyramidChartKey = GlobalKey();
                      });
                      setModalState(() {});
                    },
                    onXAxisChanged: (v) {
                      setState(() => _xAxisColumn = v);
                      setModalState(() {});
                    },
                    onYAxisChanged: (v) {
                      setState(() {
                        _yAxisColumns = v;
                        _cartesianChartKey = GlobalKey();
                        _circularChartKey = GlobalKey();
                        _funnelChartKey = GlobalKey();
                        _pyramidChartKey = GlobalKey();
                      });
                      setModalState(() {});
                    },
                    onShowLegendChanged: (v) {
                      setState(() => _showLegend = v);
                      setModalState(() {});
                    },
                    onShowDataLabelsChanged: (v) {
                      setState(() => _showDataLabels = v);
                      setModalState(() {});
                    },
                    onShowTooltipChanged: (v) {
                      setState(() => _showTooltip = v);
                      setModalState(() {});
                    },
                    onIsTransposedChanged: (v) {
                      setState(() => _isTransposed = v);
                      setModalState(() {});
                    },
                    onTitleChanged: () {
                      setState(() {});
                      setModalState(() {});
                    },
                    onExportPDF: () {
                      Navigator.pop(context);
                      _exportToPDF();
                    },
                    onExportExcel: () {
                      Navigator.pop(context);
                      _exportToExcel();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ).then((_) => setState(() {}));
  }

  Widget _buildHeader({required bool fullScreen, required bool isMobile}) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (!fullScreen) {
          setState(() => _position += details.delta);
        }
      },
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: widget.configuration.primaryColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacityNew(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (isMobile) ...[
              IconButton(
                icon: Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.arrow_back_ios_new
                      : Icons.arrow_back_ios,
                  color: widget.configuration.chartIconColor!,
                ),
                onPressed: widget.onClose,
              ),
              const SizedBox(width: 8),
            ],
            Icon(
              Icons.insights,
              color: widget.configuration.chartIconColor!.withOpacityNew(0.8),
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              widget.configuration.labels.chartAnalysis,
              style: TextStyle(
                color: widget.configuration.chartTitleColor!,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            Material(
              color: Colors.transparent,
              child: Row(
                children: [
                  if (isMobile)
                    IconButton(
                      tooltip: widget.configuration.labels.settings,
                      icon: Icon(
                        Icons.tune,
                        color: widget.configuration.chartIconColor!,
                      ),
                      onPressed: () => _showMobileSettings(0),
                    ),
                  if (!isMobile) ...[
                    IconButton(
                      tooltip: fullScreen
                          ? widget.configuration.labels.exitFullScreen
                          : widget.configuration.labels.fullScreen,
                      icon: Icon(
                        fullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                        color: widget.configuration.fullScreenButtonColor!,
                        size: 22,
                      ),
                      onPressed: () =>
                          setState(() => _isFullScreen = !_isFullScreen),
                    ),
                    IconButton(
                      tooltip: widget.configuration.labels.closeChart,
                      icon: Icon(
                        Icons.close,
                        color: widget.configuration.closeButtonColor!,
                        size: 22,
                      ),
                      onPressed: widget.onClose,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartRenderer() {
    final Map<String, String> columnTitles = {
      for (var col in widget.columns) col.column.key: col.column.title,
    };

    return OmChartRenderer(
      selectedChartType: _selectedChartType,
      rawData: widget.data,
      title: _titleController.text,
      showLegend: _showLegend,
      showDataLabels: _showDataLabels,
      showTooltip: _showTooltip,
      isTransposed: _isTransposed,
      xAxisKey: _xAxisColumn,
      yAxisKeys: _yAxisColumns,
      columnTitles: columnTitles,
      cartesianChartKey: _cartesianChartKey,
      circularChartKey: _circularChartKey,
      funnelChartKey: _funnelChartKey,
      pyramidChartKey: _pyramidChartKey,
    );
  }
}
