import 'package:om_data_grid/src/models/grid_column_model.dart';
import 'package:om_data_grid/src/enums/grid_row_type_enum.dart';
import 'package:om_data_grid/src/models/advanced_filter_model.dart';
import 'package:om_data_grid/src/utils/general_helpers.dart';
import 'package:intl/intl.dart';

class FilterUtils {
  static List<dynamic> performFiltering({
    required List<dynamic> data,
    required List<GridColumnModel> allColumns,
    String? globalSearch,
  }) {
    List<dynamic> filteredData = [];

    final String? globalSearchLC = globalSearch?.toLowerCase();

    for (var item in data) {
      bool shouldInclude = true;

      // Check Global Search First (OR across all searchable columns)
      if (globalSearchLC != null && globalSearchLC.isNotEmpty) {
        bool matchesGlobal = false;
        for (var col in allColumns) {
          if (col.isVisible) {
            String cellValue = getDisplayValue(
              item[col.key],
              col,
            ).toLowerCase();
            if (cellValue.contains(globalSearchLC)) {
              matchesGlobal = true;
              break;
            }
          }
        }
        if (!matchesGlobal) {
          shouldInclude = false;
        }
      }

      if (!shouldInclude) continue;

      for (var col in allColumns) {
        // Check Quick Filter (Contains)
        if (col.quickFilterText != null && col.quickFilterText!.isNotEmpty) {
          if (col.type == GridRowTypeEnum.date ||
              col.type == GridRowTypeEnum.dateTime ||
              col.type == GridRowTypeEnum.time) {
            final bool isTimeType = col.type == GridRowTypeEnum.time;

            // Handle range if it has a separator |
            if (col.quickFilterText!.contains('|')) {
              final parts = col.quickFilterText!.split('|');
              final start = GridDateTimeUtils.tryParse(
                parts[0],
                isTime: isTimeType,
                pattern: col.customDateFormat,
              );
              final end = parts.length > 1
                  ? GridDateTimeUtils.tryParse(
                      parts[1],
                      isTime: isTimeType,
                      pattern: col.customDateFormat,
                    )
                  : null;
              final cellValue = item[col.key];

              final DateTime? dateValue = GridDateTimeUtils.tryParse(
                cellValue,
                isTime: isTimeType,
                pattern: col.customDateFormat,
              );

              if (dateValue != null && start != null && end != null) {
                if (dateValue.isBefore(start) || dateValue.isAfter(end)) {
                  shouldInclude = false;
                  break;
                }
              }
            } else {
              // Single date check using display value
              String displayValue = getDisplayValue(
                item[col.key],
                col,
              ).toLowerCase();
              if (!displayValue.contains(col.quickFilterText!.toLowerCase())) {
                shouldInclude = false;
                break;
              }
            }
          } else {
            String displayValue = getDisplayValue(
              item[col.key],
              col,
            ).toLowerCase();
            if (!displayValue.contains(col.quickFilterText!.toLowerCase())) {
              shouldInclude = false;
              break;
            }
          }
        }

        if (col.advancedFilter != null &&
            col.advancedFilter!.conditions.isNotEmpty) {
          if (!evaluateAdvancedFilter(
            item[col.key],
            col.advancedFilter!,
            col,
          )) {
            shouldInclude = false;
            break;
          }
        }

        if (col.filter == true &&
            col.notSelectedFilterData != null &&
            col.notSelectedFilterData!.isNotEmpty) {
          dynamic cellValue = item[col.key];

          if (col.type == GridRowTypeEnum.comboBox &&
              col.comboBoxSettings?.multipleSelect == true) {
            List<String> currentValues = [];
            if (cellValue is List) {
              for (var val in cellValue) {
                if (val is GridComboBoxItem) {
                  currentValues.add(val.value.toString());
                } else if (val is Map) {
                  String keyTwo = col.comboBoxSettings?.valueKey ?? "";
                  if (keyTwo.isNotEmpty) {
                    currentValues.add(val[keyTwo].toString());
                  } else {
                    currentValues.add(val.toString());
                  }
                } else {
                  currentValues.add(val.toString());
                }
              }
            }

            // For multiple select, if even one value is NOT excluded, we include the row?
            // Actually, let's look at how GridFilterBody does it.
            // It seems to check if the item is in getDuplicatedNotSelected.

            bool isExcludedByThisColumn = true;
            for (var val in currentValues) {
              bool valIsExcluded = col.notSelectedFilterData!.any(
                (ns) => ns["value"] == val,
              );
              if (!valIsExcluded) {
                isExcludedByThisColumn = false;
                break;
              }
            }

            if (isExcludedByThisColumn) {
              shouldInclude = false;
              break;
            }
          } else {
            String itemValue = cellValue?.toString() ?? "None";
            bool isNotSelected = col.notSelectedFilterData!.any(
              (ns) => ns["value"] == itemValue,
            );

            if (isNotSelected) {
              shouldInclude = false;
              break;
            }
          }
        }
      }

      if (shouldInclude) {
        filteredData.add(item);
      }
    }

    return filteredData;
  }

  static String getDisplayValue(dynamic value, GridColumnModel col) {
    if (value == null) return "None";

    switch (col.type) {
      case GridRowTypeEnum.comboBox:
        final options = col.comboBoxSettings?.items;
        if (options != null) {
          if (col.multiSelect == true && value is List) {
            return value
                .map((v) {
                  final option = options.firstWhere(
                    (o) => o.value == v.toString(),
                    orElse: () => GridComboBoxItem(
                      value: v.toString(),
                      text: v.toString(),
                    ),
                  );
                  return option.text;
                })
                .join(', ');
          } else {
            final option = options.firstWhere(
              (o) => o.value == value.toString(),
              orElse: () => GridComboBoxItem(
                value: value.toString(),
                text: value.toString(),
              ),
            );
            return option.text;
          }
        }
        return value.toString();

      case GridRowTypeEnum.iosSwitch:
        bool isTrue = false;
        if (value is bool) {
          isTrue = value;
        } else if (value is int) {
          isTrue = value == 1;
        } else if (value is String) {
          isTrue = value.toLowerCase() == 'true';
        }
        return isTrue ? "true" : "false";

      case GridRowTypeEnum.date:
      case GridRowTypeEnum.dateTime:
      case GridRowTypeEnum.time:
        final bool isTimeType = col.type == GridRowTypeEnum.time;
        final date = GridDateTimeUtils.tryParse(value, isTime: isTimeType);
        if (date != null) {
          if (col.customDateFormat != null) {
            try {
              return DateFormat(col.customDateFormat).format(date);
            } catch (e) {
              return date.toIso8601String();
            }
          }
          return DateFormat.yMd().format(date);
        }
        return value.toString();

      case GridRowTypeEnum.double:
      case GridRowTypeEnum.integer:
        if (value is num ||
            (value is String && double.tryParse(value) != null)) {
          final double val = value is num
              ? value.toDouble()
              : double.parse(value);
          final int digits =
              col.decimalDigits ?? (col.type == GridRowTypeEnum.double ? 2 : 0);
          final String decimalSeparator = col.decimalSeparator ?? '.';
          final String thousandsSeparator = col.thousandsSeparator ?? '';

          String fixed = val.toStringAsFixed(digits);
          List<String> parts = fixed.split('.');
          String integerPart = parts[0];
          String decimalPart = parts.length > 1 ? parts[1] : '';

          if (thousandsSeparator.isNotEmpty) {
            final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
            integerPart = integerPart.replaceAllMapped(
              reg,
              (Match m) => '${m[1]}$thousandsSeparator',
            );
          }

          String formatted = integerPart;
          if (digits > 0) {
            formatted += decimalSeparator + decimalPart;
          }
          return formatted;
        }
        return value.toString();

      default:
        return value.toString();
    }
  }

  static bool evaluateAdvancedFilter(
    dynamic cellValue,
    AdvancedFilterModel filter,
    GridColumnModel col,
  ) {
    if (filter.conditions.isEmpty) return true;

    // Convert cell value to string for comparison mostly
    String strValue = getDisplayValue(cellValue, col).toLowerCase();

    num? numValue;
    DateTime? dateValue;

    if (cellValue is num) {
      numValue = cellValue;
    } else if (cellValue is String) {
      numValue = num.tryParse(cellValue);
    }

    final bool isTimeType = col.type == GridRowTypeEnum.time;
    dateValue = GridDateTimeUtils.tryParse(
      cellValue,
      isTime: isTimeType,
      pattern: col.customDateFormat,
    );

    bool checkCondition(FilterCondition condition) {
      String condValue = condition.value.toLowerCase();
      num? condNum = num.tryParse(condition.value);
      DateTime? condDate = GridDateTimeUtils.tryParse(
        condition.value,
        isTime: isTimeType,
        pattern: col.customDateFormat,
      );

      switch (condition.type) {
        case FilterConditionType.equals:
          if (dateValue != null && condDate != null) {
            return dateValue.isAtSameMomentAs(condDate);
          }
          return strValue == condValue;
        case FilterConditionType.notEqual:
          if (dateValue != null && condDate != null) {
            return !dateValue.isAtSameMomentAs(condDate);
          }
          return strValue != condValue;
        case FilterConditionType.contains:
          return strValue.contains(condValue);
        case FilterConditionType.notContains:
          return !strValue.contains(condValue);
        case FilterConditionType.startsWith:
          return strValue.startsWith(condValue);
        case FilterConditionType.endsWith:
          return strValue.endsWith(condValue);
        case FilterConditionType.greaterThan:
          if (dateValue != null && condDate != null) {
            return dateValue.isAfter(condDate);
          }
          if (numValue != null && condNum != null) return numValue > condNum;
          return strValue.compareTo(condValue) > 0;
        case FilterConditionType.lessThan:
          if (dateValue != null && condDate != null) {
            return dateValue.isBefore(condDate);
          }
          if (numValue != null && condNum != null) return numValue < condNum;
          return strValue.compareTo(condValue) < 0;
        case FilterConditionType.greaterThanOrEqual:
          if (dateValue != null && condDate != null) {
            return dateValue.isAfter(condDate) ||
                dateValue.isAtSameMomentAs(condDate);
          }
          if (numValue != null && condNum != null) return numValue >= condNum;
          return strValue.compareTo(condValue) >= 0;
        case FilterConditionType.lessThanOrEqual:
          if (dateValue != null && condDate != null) {
            return dateValue.isBefore(condDate) ||
                dateValue.isAtSameMomentAs(condDate);
          }
          if (numValue != null && condNum != null) return numValue <= condNum;
          return strValue.compareTo(condValue) <= 0;
        case FilterConditionType.empty:
          return strValue.isEmpty || cellValue == null;
        case FilterConditionType.notEmpty:
          return strValue.isNotEmpty && cellValue != null;
        case FilterConditionType.between:
          String condValueTo = condition.valueTo.toLowerCase();
          num? condNumTo = num.tryParse(condition.valueTo);
          DateTime? condDateTo = GridDateTimeUtils.tryParse(
            condition.valueTo,
            isTime: isTimeType,
            pattern: col.customDateFormat,
          );

          if (dateValue != null && condDate != null && condDateTo != null) {
            return (dateValue.isAfter(condDate) ||
                    dateValue.isAtSameMomentAs(condDate)) &&
                (dateValue.isBefore(condDateTo) ||
                    dateValue.isAtSameMomentAs(condDateTo));
          }
          if (numValue != null && condNum != null && condNumTo != null) {
            return numValue >= condNum && numValue <= condNumTo;
          }
          return strValue.compareTo(condValue) >= 0 &&
              strValue.compareTo(condValueTo) <= 0;
      }
    }

    final activeConditions = filter.conditions.where((c) {
      if (c.type == FilterConditionType.empty ||
          c.type == FilterConditionType.notEmpty) {
        return true;
      }
      if (c.type == FilterConditionType.between) {
        return c.value.trim().isNotEmpty && c.valueTo.trim().isNotEmpty;
      }
      return c.value.trim().isNotEmpty;
    }).toList();

    if (activeConditions.isEmpty) return true;

    if (filter.operator == FilterOperator.and) {
      return activeConditions.every(checkCondition);
    } else {
      return activeConditions.any(checkCondition);
    }
  }

  static List<Map<String, dynamic>> getExcludedValuesForSelection({
    required List<dynamic> data,
    required String columnKey,
    required dynamic selectedValue,
  }) {
    final Set<String> allValues = data
        .map((item) => item[columnKey]?.toString() ?? "None")
        .toSet();
    final String selectedStr = selectedValue?.toString() ?? "None";

    return allValues
        .where((v) => v != selectedStr)
        .map((v) => {"value": v, "label": v})
        .toList();
  }
}
