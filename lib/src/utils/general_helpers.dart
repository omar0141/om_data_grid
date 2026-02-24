import 'package:om_data_grid/src/datagrid.dart';
import 'package:om_data_grid/src/models/datagrid_configuration.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:om_data_grid/src/utils/file_viewer/file_viewer.dart';

class OmStringUtils {
  static List<int> getNumberIndices(String input) {
    List<int> indices = [];
    for (int i = 0; i < input.length; i++) {
      if (int.tryParse(input[i]) != null) {
        indices.add(i);
      }
    }
    return indices;
  }
}

class OmGridDateTimeUtils {
  static DateTime? tryParse(
    dynamic value, {
    bool isTime = false,
    String? pattern,
  }) {
    if (value is DateTime) return value;
    if (value == null || value.toString().isEmpty) return null;

    final String valStr = value.toString();

    // 1. Try with custom pattern if provided
    if (pattern != null && pattern.isNotEmpty) {
      try {
        return DateFormat(pattern).parse(valStr);
      } catch (_) {}
    }

    // 2. Try Standard ISO
    DateTime? parsed = DateTime.tryParse(valStr);

    // 3. Try manual fragments (HH:mm)
    if (parsed == null && (isTime || valStr.contains(':'))) {
      try {
        final parts = valStr.split(':');
        if (parts.length >= 2) {
          final now = DateTime.now();
          return DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(parts[0]),
            int.parse(parts[1]),
            parts.length > 2 ? int.parse(parts[2].split('.').first) : 0,
          );
        }
      } catch (_) {}
    }
    return parsed;
  }
}

class OmTimeRange {
  final TimeOfDay start;
  final TimeOfDay end;

  OmTimeRange({required this.start, required this.end});
}

extension StringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;
}

extension ListExtensions on List? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;
}

extension SizeExtensions on num? {
  double get sw => this == null ? 0 : this!.toDouble() * screenWidth;
  double get sh => this == null ? 0 : this!.toDouble() * screenHeight;
}

double mySize({double? xs, double? sm, double? md, double? lg, double? xl}) {
  double? width = screenWidth;
  double? newWidth = width;
  sm ??= xs;
  md ??= sm;
  lg ??= md;
  xl ??= lg;
  if (width >= 0) newWidth = xs;
  if (width >= 576) newWidth = sm;
  if (width >= 768) newWidth = md;
  if (width >= 992) newWidth = lg;
  if (width >= 1200) newWidth = xl;
  return newWidth ?? 0;
}

extension ColorOpacity on Color? {
  Color withOpacityNew(double value) {
    return this?.withAlpha((value * 255).toInt()) ?? Colors.black;
  }
}

class GridDatePickerUtils {
  static Future<DateTimeRange?> showModernDateRangePicker({
    required BuildContext context,
    required OmDataGridConfiguration configuration,
    DateTimeRange? initialDateRange,
  }) async {
    DateTimeRange? tempResult = initialDateRange;
    return await showDialog<DateTimeRange>(
      context: context,
      builder: (context) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750, maxHeight: 500),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Material(
                color: configuration.menuBackgroundColor ?? Colors.white,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Select Date Range",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: configuration.rowForegroundColor,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      Expanded(
                        child: SfDateRangePicker(
                          onSelectionChanged:
                              (DateRangePickerSelectionChangedArgs args) {
                            if (args.value is PickerDateRange) {
                              if (args.value.startDate != null &&
                                  args.value.endDate != null) {
                                tempResult = DateTimeRange(
                                  start: args.value.startDate,
                                  end: args.value.endDate,
                                );
                              }
                            }
                          },
                          selectionMode: DateRangePickerSelectionMode.range,
                          enableMultiView: true,
                          navigationDirection:
                              DateRangePickerNavigationDirection.horizontal,
                          headerHeight: 60,
                          initialSelectedRange: initialDateRange != null
                              ? PickerDateRange(
                                  initialDateRange.start,
                                  initialDateRange.end,
                                )
                              : null,
                          headerStyle: DateRangePickerHeaderStyle(
                            backgroundColor:
                                configuration.headerBackgroundColor,
                            textAlign: TextAlign.center,
                            textStyle: TextStyle(
                              color: configuration.rowForegroundColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          monthViewSettings:
                              const DateRangePickerMonthViewSettings(
                            firstDayOfWeek: 1,
                            dayFormat: 'EEE',
                            viewHeaderStyle: DateRangePickerViewHeaderStyle(
                              textStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          backgroundColor: configuration.menuBackgroundColor,
                          selectionColor: configuration.primaryColor,
                          startRangeSelectionColor: configuration.primaryColor,
                          endRangeSelectionColor: configuration.primaryColor,
                          rangeSelectionColor:
                              configuration.primaryColor.withOpacity(0.12),
                          todayHighlightColor: configuration.primaryColor,
                          selectionTextStyle: TextStyle(
                            color: configuration.primaryForegroundColor,
                          ),
                          rangeTextStyle: TextStyle(
                            color: configuration.rowForegroundColor,
                          ),
                          monthCellStyle: DateRangePickerMonthCellStyle(
                            todayTextStyle: TextStyle(
                              color: configuration.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                            textStyle: TextStyle(
                              color: configuration.rowForegroundColor,
                              fontSize: 13,
                            ),
                          ),
                          yearCellStyle: DateRangePickerYearCellStyle(
                            todayTextStyle: TextStyle(
                              color: configuration.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                            textStyle: TextStyle(
                              color: configuration.rowForegroundColor,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: configuration.primaryColor,
                              foregroundColor:
                                  configuration.primaryForegroundColor,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context, tempResult),
                            child: const Text("Apply Range"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<DateTime?> showModernDatePicker({
    required BuildContext context,
    required OmDataGridConfiguration configuration,
    DateTime? initialDate,
  }) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: _getPickerTheme(context, configuration),
          child: child!,
        );
      },
    );
  }

  static Future<TimeOfDay?> showModernTimePicker({
    required BuildContext context,
    required OmDataGridConfiguration configuration,
    TimeOfDay? initialTime,
  }) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: _getPickerTheme(context, configuration).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: configuration.menuBackgroundColor,
              dayPeriodColor: configuration.primaryColor.withOpacity(0.15),
              dayPeriodTextColor: configuration.rowForegroundColor,
              dialHandColor: configuration.primaryColor,
              dialBackgroundColor: configuration.primaryColor.withOpacity(0.05),
              entryModeIconColor: configuration.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              cancelButtonStyle: TextButton.styleFrom(
                foregroundColor: configuration.rowForegroundColor.withOpacity(
                  0.6,
                ),
              ),
              confirmButtonStyle: TextButton.styleFrom(
                foregroundColor: configuration.primaryColor,
                textStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600, // Even wider
                maxHeight: 650,
              ),
              child: Transform.scale(
                scale: 1.2, // Larger
                child: child!,
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<OmTimeRange?> showModernTimeRangePicker({
    required BuildContext context,
    required OmDataGridConfiguration configuration,
    OmTimeRange? initialTimeRange,
  }) async {
    TimeOfDay start =
        initialTimeRange?.start ?? const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay end =
        initialTimeRange?.end ?? const TimeOfDay(hour: 17, minute: 0);

    return await showDialog<OmTimeRange>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Material(
                    color: configuration.menuBackgroundColor ?? Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Select Time Range",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: configuration.rowForegroundColor,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTimeSelector(
                                  context,
                                  "Start Time",
                                  start,
                                  configuration,
                                  (val) => setState(() => start = val),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: Colors.grey,
                                ),
                              ),
                              Expanded(
                                child: _buildTimeSelector(
                                  context,
                                  "End Time",
                                  end,
                                  configuration,
                                  (val) => setState(() => end = val),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: configuration.primaryColor,
                                  foregroundColor:
                                      configuration.primaryForegroundColor,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 28,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(
                                  context,
                                  OmTimeRange(start: start, end: end),
                                ),
                                child: const Text("Apply"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildTimeSelector(
    BuildContext context,
    String label,
    TimeOfDay time,
    OmDataGridConfiguration configuration,
    void Function(TimeOfDay) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            TimeOfDay? picked = await showModernTimePicker(
              context: context,
              configuration: configuration,
              initialTime: time,
            );
            if (picked != null) onChanged(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: configuration.inputBorderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time.format(context),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: configuration.rowForegroundColor,
                  ),
                ),
                const Icon(Icons.access_time, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static ThemeData _getPickerTheme(
    BuildContext context,
    OmDataGridConfiguration configuration,
  ) {
    final Color primary = configuration.primaryColor;
    final Color surface = configuration.menuBackgroundColor ?? Colors.white;
    final Color onSurface = configuration.rowForegroundColor;

    return Theme.of(context).copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        onPrimary: configuration.primaryForegroundColor,
        surface: surface,
        onSurface: onSurface,
        secondary: primary,
      ),
      dialogBackgroundColor: surface,
      scaffoldBackgroundColor: surface,
      cardColor: surface,
      shadowColor: Colors.transparent,
      dividerColor: Colors.transparent,
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class GridFileViewerUtils {
  static Future<void> showViewer({
    required BuildContext context,
    required String url,
    required String title,
    required OmDataGridConfiguration configuration,
    bool isImage = false,
  }) async {
    await showDialog(
      context: context,
      builder: (context) {
        if (isImage) {
          return Dialog(
            backgroundColor: Colors.black,
            insetPadding: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 900),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Center(
                        child: Image.network(
                          url,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCircularButton(
                          icon: Icons.close,
                          onTap: () => Navigator.pop(context),
                          tooltip: "Close",
                        ),
                        _buildCircularButton(
                          icon: Icons.download,
                          onTap: () => _downloadFile(url, title),
                          tooltip: "Download",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800, maxHeight: 800),
            decoration: BoxDecoration(
              color: configuration.menuBackgroundColor ?? Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    title,
                    style: TextStyle(
                      color: configuration.rowForegroundColor,
                      fontSize: 16,
                    ),
                  ),
                  centerTitle: true,
                  leading: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: configuration.rowForegroundColor,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.download,
                        color: configuration.rowForegroundColor,
                      ),
                      onPressed: () => _downloadFile(url, title),
                    ),
                  ],
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.insert_drive_file,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Click to open file in system viewer",
                            style: TextStyle(
                              color: configuration.secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: configuration.primaryColor,
                              foregroundColor:
                                  configuration.primaryForegroundColor,
                            ),
                            onPressed: () => _openSystemFile(url),
                            icon: const Icon(Icons.open_in_new),
                            label: const Text("Open File"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? "",
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.4),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  static Future<void> _downloadFile(String url, String fileName) async {
    await FileViewer.downloadAndOpen(url, fileName);
  }

  static Future<void> _openSystemFile(String url) async {
    await FileViewer.open(url);
  }
}

class GridUtils {
  static bool isPointInsideKey(Offset globalPosition, GlobalKey? key) {
    if (key == null || key.currentContext == null) return false;
    final RenderBox? renderBox =
        key.currentContext!.findRenderObject() as RenderBox?;
    if (renderBox == null) return false;
    final Offset localPosition = renderBox.globalToLocal(globalPosition);
    return localPosition.dx >= 0 &&
        localPosition.dy >= 0 &&
        localPosition.dx <= renderBox.size.width &&
        localPosition.dy <= renderBox.size.height;
  }
}
