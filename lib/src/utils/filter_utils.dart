import 'package:om_data_grid/src/models/datagrid_labels.dart';
import 'package:om_data_grid/src/models/grid_column_model.dart';
import 'package:om_data_grid/src/enums/grid_row_type_enum.dart';
import 'package:om_data_grid/src/models/advanced_filter_model.dart';
import 'package:om_data_grid/src/models/datagrid_configuration.dart';
import 'package:om_data_grid/src/utils/general_helpers.dart';
import 'package:intl/intl.dart';

class OmFilterUtils {
  static List<dynamic> performFiltering({
    required List<dynamic> data,
    required List<OmGridColumnModel> allColumns,
    String? globalSearch,
    OmDataGridConfiguration? configuration,
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
              configuration,
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
          if (col.type == OmGridRowTypeEnum.date ||
              col.type == OmGridRowTypeEnum.dateTime ||
              col.type == OmGridRowTypeEnum.time) {
            final bool isTimeType = col.type == OmGridRowTypeEnum.time;

            // Handle range if it has a separator |
            if (col.quickFilterText!.contains('|')) {
              final parts = col.quickFilterText!.split('|');
              final start = OmGridDateTimeUtils.tryParse(
                parts[0],
                isTime: isTimeType,
                pattern: col.customDateFormat,
              );
              final end = parts.length > 1
                  ? OmGridDateTimeUtils.tryParse(
                      parts[1],
                      isTime: isTimeType,
                      pattern: col.customDateFormat,
                    )
                  : null;
              final cellValue = item[col.key];

              final DateTime? dateValue = OmGridDateTimeUtils.tryParse(
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
                configuration,
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
              configuration,
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
            configuration,
          )) {
            shouldInclude = false;
            break;
          }
        }

        if (col.filter == true &&
            col.notSelectedFilterData != null &&
            col.notSelectedFilterData!.isNotEmpty) {
          dynamic cellValue = item[col.key];

          if (col.type == OmGridRowTypeEnum.comboBox &&
              col.comboBoxSettings?.multipleSelect == true) {
            List<String> currentValues = [];
            if (cellValue is List) {
              for (var val in cellValue) {
                if (val is OmGridComboBoxItem) {
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
            String itemValue =
                cellValue?.toString() ?? configuration?.labels.none ?? "None";
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

  static String getDisplayValue(
    dynamic value,
    OmGridColumnModel col, [
    OmDataGridConfiguration? config,
  ]) {
    final labels = config?.labels ?? const OmDataGridLabels();
    if (value == null) return labels.none;

    switch (col.type) {
      case OmGridRowTypeEnum.comboBox:
        final options = col.comboBoxSettings?.items;
        if (options != null) {
          if (col.multiSelect == true && value is List) {
            return value.map((v) {
              final option = options.firstWhere(
                (o) => o.value == v.toString(),
                orElse: () => OmGridComboBoxItem(
                  value: v.toString(),
                  text: v.toString(),
                ),
              );
              return option.text;
            }).join(', ');
          } else {
            final option = options.firstWhere(
              (o) => o.value == value.toString(),
              orElse: () => OmGridComboBoxItem(
                value: value.toString(),
                text: value.toString(),
              ),
            );
            return option.text;
          }
        }
        return value.toString();

      case OmGridRowTypeEnum.iosSwitch:
        bool isTrue = false;
        if (value is bool) {
          isTrue = value;
        } else if (value is int) {
          isTrue = value == 1;
        } else if (value is String) {
          isTrue = value.toLowerCase() == 'true';
        }
        return isTrue ? labels.trueText : labels.falseText;

      case OmGridRowTypeEnum.date:
      case OmGridRowTypeEnum.dateTime:
      case OmGridRowTypeEnum.time:
        final bool isTimeType = col.type == OmGridRowTypeEnum.time;
        final date = OmGridDateTimeUtils.tryParse(value, isTime: isTimeType);
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

      case OmGridRowTypeEnum.double:
      case OmGridRowTypeEnum.integer:
        if (value is num ||
            (value is String && double.tryParse(value) != null)) {
          final double val =
              value is num ? value.toDouble() : double.parse(value);
          final int digits = col.decimalDigits ??
              (col.type == OmGridRowTypeEnum.double ? 2 : 0);
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
    OmAdvancedFilterModel filter,
    OmGridColumnModel col, [
    OmDataGridConfiguration? config,
  ]) {
    if (filter.conditions.isEmpty) return true;

    // Convert cell value to string for comparison mostly
    String strValue = getDisplayValue(cellValue, col, config).toLowerCase();

    num? numValue;
    DateTime? dateValue;

    if (cellValue is num) {
      numValue = cellValue;
    } else if (cellValue is String) {
      numValue = num.tryParse(cellValue);
    }

    final bool isTimeType = col.type == OmGridRowTypeEnum.time;
    dateValue = OmGridDateTimeUtils.tryParse(
      cellValue,
      isTime: isTimeType,
      pattern: col.customDateFormat,
    );

    bool checkCondition(OmFilterCondition condition) {
      String condValue = condition.value.toLowerCase();
      num? condNum = num.tryParse(condition.value);
      DateTime? condDate = OmGridDateTimeUtils.tryParse(
        condition.value,
        isTime: isTimeType,
        pattern: col.customDateFormat,
      );

      switch (condition.type) {
        case OmFilterConditionType.equals:
          if (dateValue != null && condDate != null) {
            return dateValue.isAtSameMomentAs(condDate);
          }
          return strValue == condValue;
        case OmFilterConditionType.notEqual:
          if (dateValue != null && condDate != null) {
            return !dateValue.isAtSameMomentAs(condDate);
          }
          return strValue != condValue;
        case OmFilterConditionType.contains:
          return strValue.contains(condValue);
        case OmFilterConditionType.notContains:
          return !strValue.contains(condValue);
        case OmFilterConditionType.startsWith:
          return strValue.startsWith(condValue);
        case OmFilterConditionType.endsWith:
          return strValue.endsWith(condValue);
        case OmFilterConditionType.greaterThan:
          if (dateValue != null && condDate != null) {
            return dateValue.isAfter(condDate);
          }
          if (numValue != null && condNum != null) return numValue > condNum;
          return strValue.compareTo(condValue) > 0;
        case OmFilterConditionType.lessThan:
          if (dateValue != null && condDate != null) {
            return dateValue.isBefore(condDate);
          }
          if (numValue != null && condNum != null) return numValue < condNum;
          return strValue.compareTo(condValue) < 0;
        case OmFilterConditionType.greaterThanOrEqual:
          if (dateValue != null && condDate != null) {
            return dateValue.isAfter(condDate) ||
                dateValue.isAtSameMomentAs(condDate);
          }
          if (numValue != null && condNum != null) return numValue >= condNum;
          return strValue.compareTo(condValue) >= 0;
        case OmFilterConditionType.lessThanOrEqual:
          if (dateValue != null && condDate != null) {
            return dateValue.isBefore(condDate) ||
                dateValue.isAtSameMomentAs(condDate);
          }
          if (numValue != null && condNum != null) return numValue <= condNum;
          return strValue.compareTo(condValue) <= 0;
        case OmFilterConditionType.empty:
          return strValue.isEmpty || cellValue == null;
        case OmFilterConditionType.notEmpty:
          return strValue.isNotEmpty && cellValue != null;
        case OmFilterConditionType.between:
          String condValueTo = condition.valueTo.toLowerCase();
          num? condNumTo = num.tryParse(condition.valueTo);
          DateTime? condDateTo = OmGridDateTimeUtils.tryParse(
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
      if (c.type == OmFilterConditionType.empty ||
          c.type == OmFilterConditionType.notEmpty) {
        return true;
      }
      if (c.type == OmFilterConditionType.between) {
        return c.value.trim().isNotEmpty && c.valueTo.trim().isNotEmpty;
      }
      return c.value.trim().isNotEmpty;
    }).toList();

    if (activeConditions.isEmpty) return true;

    if (filter.operator == OmFilterOperator.and) {
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
    final Set<String> allValues =
        data.map((item) => item[columnKey]?.toString() ?? "None").toSet();
    final String selectedStr = selectedValue?.toString() ?? "None";

    return allValues
        .where((v) => v != selectedStr)
        .map((v) => {"value": v, "label": v})
        .toList();
  }
}
