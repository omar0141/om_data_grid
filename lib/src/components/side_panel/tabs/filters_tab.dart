import 'package:om_data_grid/src/components/grid_combo_box/grid_combo_box.dart';
import 'package:om_data_grid/src/enums/grid_row_type_enum.dart';
import 'package:om_data_grid/src/models/advanced_filter_model.dart';
import 'package:om_data_grid/src/models/datagrid_configuration.dart';
import 'package:om_data_grid/src/models/grid_column_model.dart';
import 'package:om_data_grid/src/utils/datagrid_controller.dart';
import 'package:om_data_grid/src/utils/filter_utils.dart';
import 'package:om_data_grid/src/utils/general_helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FiltersTab extends StatefulWidget {
  final OmDataGridController controller;

  const FiltersTab({super.key, required this.controller});

  @override
  State<FiltersTab> createState() => _FiltersTabState();
}

class _FiltersTabState extends State<FiltersTab> {
  final Set<String> _activeFilterColumns = {};

  @override
  void initState() {
    super.initState();
    _syncActiveFilters();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {
        _syncActiveFilters();
      });
    }
  }

  void _syncActiveFilters() {
    _activeFilterColumns.clear();
    for (var col in widget.controller.columnModels) {
      if (col.advancedFilter != null) {
        _activeFilterColumns.add(col.key);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filterableColumns = widget.controller.columnModels
        .where(
          (c) =>
              c.column.allowFiltering && !_activeFilterColumns.contains(c.key),
        )
        .toList();

    final comboItems = filterableColumns
        .map((col) => OmGridComboBoxItem(value: col.key, text: col.title))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridComboBox(
            items: comboItems,
            initialText: "Add Filter",
            height: 36,
            borderRadius: 4,
            fontSize: 13,
            showClearButton: false,
            enableSearch: true,
            value: "",
            borderColor: widget.controller.configuration.rowBorderColor,
            onChange: (value) {
              if (value != null) {
                setState(() {
                  _activeFilterColumns.add(value as String);
                  final col = widget.controller.columnModels.firstWhere(
                    (c) => c.key == value,
                  );
                  col.filter = true;
                  if (col.advancedFilter == null) {
                    col.advancedFilter = OmAdvancedFilterModel(
                      conditions: [OmFilterCondition()],
                    );
                  } else if (col.advancedFilter!.conditions.isEmpty) {
                    col.advancedFilter!.conditions.add(OmFilterCondition());
                  }
                });
              }
            },
            configuration: widget.controller.configuration,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: _activeFilterColumns.map((key) {
              final col = widget.controller.columnModels.firstWhere(
                (c) => c.key == key,
              );
              return _FilterCard(
                key: ValueKey(col.key),
                columnModel: col,
                configuration: widget.controller.configuration,
                onRemove: () {
                  setState(() {
                    _activeFilterColumns.remove(key);
                    col.advancedFilter?.conditions.clear();
                    col.filter = false;
                    col.quickFilterText = null;
                    col.notSelectedFilterData = [];
                    col.advancedFilter = null;
                    col.filter =
                        (col.notSelectedFilterData != null &&
                        col.notSelectedFilterData!.isNotEmpty);
                    _applyFilters();
                  });
                },
                onApply: _applyFilters,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _applyFilters() {
    final newData = OmFilterUtils.performFiltering(
      data: widget.controller.data,
      allColumns: widget.controller.columnModels,
      globalSearch: widget.controller.globalSearchText,
    ).map((e) => Map<String, dynamic>.from(e)).toList();

    widget.controller.updateFilteredData(newData);
  }
}

class _FilterCard extends StatefulWidget {
  final OmGridColumnModel columnModel;
  final VoidCallback onRemove;
  final VoidCallback onApply;
  final OmDataGridConfiguration configuration;

  const _FilterCard({
    super.key,
    required this.columnModel,
    required this.onRemove,
    required this.onApply,
    required this.configuration,
  });

  @override
  State<_FilterCard> createState() => _FilterCardState();
}

class _FilterCardState extends State<_FilterCard> {
  late TextEditingController _textController1;
  late TextEditingController _textController2;
  late TextEditingController _textController1To;
  late TextEditingController _textController2To;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    final adv = widget.columnModel.advancedFilter;
    final val1 = (adv != null && adv.conditions.isNotEmpty)
        ? adv.conditions.first.value
        : "";
    _textController1 = TextEditingController(text: val1);

    final val1To = (adv != null && adv.conditions.isNotEmpty)
        ? adv.conditions.first.valueTo
        : "";
    _textController1To = TextEditingController(text: val1To);

    final val2 = (adv != null && adv.conditions.length > 1)
        ? adv.conditions[1].value
        : "";
    _textController2 = TextEditingController(text: val2);

    final val2To = (adv != null && adv.conditions.length > 1)
        ? adv.conditions[1].valueTo
        : "";
    _textController2To = TextEditingController(text: val2To);
  }

  @override
  void dispose() {
    _textController1.dispose();
    _textController2.dispose();
    _textController1To.dispose();
    _textController2To.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final advancedFilter = widget.columnModel.advancedFilter ??=
        OmAdvancedFilterModel(conditions: [OmFilterCondition()]);
    if (advancedFilter.conditions.isEmpty) {
      advancedFilter.conditions.add(OmFilterCondition());
    }
    if (advancedFilter.conditions.length < 2) {
      advancedFilter.conditions.add(OmFilterCondition());
    }

    final condition1 = advancedFilter.conditions[0];
    final condition2 = advancedFilter.conditions[1];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: widget.configuration.filterTabItemBackgroundColor!,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.configuration.filterTabItemBorderColor!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.columnModel.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: widget.configuration.filterTabItemParamsColor!,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: widget.configuration.filterTabItemIconColor!,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: widget.onRemove,
                    icon: const Icon(Icons.close),
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: widget.configuration.filterTabItemIconColor!,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            _buildConditionSection(
              condition1,
              _textController1,
              _textController1To,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _buildOperatorRadio(
                    "And",
                    OmFilterOperator.and,
                    advancedFilter,
                  ),
                  const SizedBox(width: 16),
                  _buildOperatorRadio("Or", OmFilterOperator.or, advancedFilter),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildConditionSection(
              condition2,
              _textController2,
              _textController2To,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: SizedBox(
                  height: 32,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        condition1.value = '';
                        condition1.valueTo = '';
                        condition2.value = '';
                        condition2.valueTo = '';
                        _textController1.text = '';
                        _textController1To.text = '';
                        _textController2.text = '';
                        _textController2To.text = '';
                        condition1.type = OmFilterConditionType.contains;
                        condition2.type = OmFilterConditionType.contains;
                        advancedFilter.operator = OmFilterOperator.and;
                      });
                      widget.onApply();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                    child: const Text(
                      "Clear",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOperatorRadio(
    String label,
    OmFilterOperator value,
    OmAdvancedFilterModel model,
  ) {
    return InkWell(
      onTap: () {
        setState(() => model.operator = value);
        widget.onApply();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Radio<OmFilterOperator>(
              value: value,
              activeColor: widget.configuration.primaryColor,
              groupValue: model.operator,
              onChanged: (val) {
                if (val != null) {
                  setState(() => model.operator = val);
                  widget.onApply();
                }
              },
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildConditionSection(
    OmFilterCondition condition,
    TextEditingController controller,
    TextEditingController controllerTo,
  ) {
    bool isBetween = condition.type == OmFilterConditionType.between;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(4),
            ),
            child: GridComboBox(
              items: OmFilterConditionType.values.map((e) {
                String label = e.toString().split('.').last;
                label = label[0].toUpperCase() + label.substring(1);
                return OmGridComboBoxItem(value: e.toString(), text: label);
              }).toList(),
              initialValue: condition.type.toString(),
              height: 36,
              borderRadius: 4,
              fontSize: 13,
              showClearButton: false,
              borderColor: Colors.grey.shade200,
              onChange: (val) {
                if (val != null) {
                  setState(() {
                    condition.type = OmFilterConditionType.values.firstWhere(
                      (e) => e.toString() == val,
                    );
                  });
                  widget.onApply();
                }
              },
              configuration: widget.configuration,
            ),
          ),
        ),
        if (condition.type != OmFilterConditionType.empty &&
            condition.type != OmFilterConditionType.notEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 36,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextField(
                    controller: controller,
                    readOnly:
                        [
                          OmGridRowTypeEnum.date,
                          OmGridRowTypeEnum.dateTime,
                          OmGridRowTypeEnum.time,
                        ].contains(widget.columnModel.type) &&
                        ![
                          OmFilterConditionType.contains,
                          OmFilterConditionType.notContains,
                          OmFilterConditionType.startsWith,
                          OmFilterConditionType.endsWith,
                        ].contains(condition.type),
                    onTap: () async {
                      if ([
                        OmFilterConditionType.contains,
                        OmFilterConditionType.notContains,
                        OmFilterConditionType.startsWith,
                        OmFilterConditionType.endsWith,
                      ].contains(condition.type)) {
                        return;
                      }
                      if (widget.columnModel.type == OmGridRowTypeEnum.date ||
                          widget.columnModel.type == OmGridRowTypeEnum.dateTime) {
                        if (condition.type == OmFilterConditionType.between) {
                          DateTime start =
                              DateTime.tryParse(condition.value) ??
                              DateTime.now();
                          DateTime end =
                              DateTime.tryParse(condition.valueTo) ??
                              DateTime.now();

                          DateTimeRange? pickedRange =
                              await GridDatePickerUtils.showModernDateRangePicker(
                                context: context,
                                configuration: widget.configuration,
                                initialDateRange: DateTimeRange(
                                  start: start,
                                  end: end,
                                ),
                              );

                          if (pickedRange != null) {
                            setState(() {
                              condition.value = pickedRange.start
                                  .toIso8601String();
                              condition.valueTo = pickedRange.end
                                  .toIso8601String();

                              final dateFormat =
                                  widget.columnModel.customDateFormat ??
                                  'yyyy-MM-dd';
                              controller.text = DateFormat(
                                dateFormat,
                              ).format(pickedRange.start);
                              controllerTo.text = DateFormat(
                                dateFormat,
                              ).format(pickedRange.end);
                            });
                            widget.onApply();
                          }
                        } else {
                          DateTime current =
                              DateTime.tryParse(condition.value) ??
                              DateTime.now();
                          DateTime? picked =
                              await GridDatePickerUtils.showModernDatePicker(
                                context: context,
                                configuration: widget.configuration,
                                initialDate: current,
                              );
                          if (picked != null) {
                            setState(() {
                              condition.value = picked.toIso8601String();
                              final dateFormat =
                                  widget.columnModel.customDateFormat ??
                                  'yyyy-MM-dd';
                              controller.text = DateFormat(
                                dateFormat,
                              ).format(picked);
                            });
                            widget.onApply();
                          }
                        }
                      } else if (widget.columnModel.type ==
                          OmGridRowTypeEnum.time) {
                        TimeOfDay? pickedTime =
                            await GridDatePickerUtils.showModernTimePicker(
                              context: context,
                              configuration: widget.configuration,
                            );
                        if (pickedTime != null) {
                          final now = DateTime.now();
                          final dt = DateTime(
                            now.year,
                            now.month,
                            now.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                          String displayVal = DateFormat(
                            widget.columnModel.customDateFormat ?? 'HH:mm',
                          ).format(dt);

                          controller.text = displayVal;
                          condition.value = displayVal;
                          widget.onApply();
                        }
                      }
                    },
                    style: const TextStyle(fontSize: 13),
                    onChanged: (val) {
                      condition.value = val;
                      widget.onApply();
                    },
                    decoration: InputDecoration(
                      hintText: isBetween ? "From..." : "Filter...",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                      contentPadding: const EdgeInsets.only(top: 4),
                      border: InputBorder.none,
                      suffixIcon: controller.text.isNotEmpty
                          ? InkWell(
                              onTap: () {
                                controller.clear();
                                condition.value = '';
                                widget.onApply();
                              },
                              child: const Icon(Icons.clear, size: 16),
                            )
                          : null,
                    ),
                  ),
                ),
                if (isBetween) ...[
                  const SizedBox(height: 8),
                  Container(
                    height: 36,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: TextField(
                      controller: controllerTo,
                      readOnly: [
                        OmGridRowTypeEnum.date,
                        OmGridRowTypeEnum.dateTime,
                        OmGridRowTypeEnum.time,
                      ].contains(widget.columnModel.type),
                      onTap: () async {
                        if (widget.columnModel.type == OmGridRowTypeEnum.date ||
                            widget.columnModel.type ==
                                OmGridRowTypeEnum.dateTime) {
                          DateTime start =
                              DateTime.tryParse(condition.value) ??
                              DateTime.now();
                          DateTime end =
                              DateTime.tryParse(condition.valueTo) ??
                              DateTime.now();

                          DateTimeRange? pickedRange =
                              await GridDatePickerUtils.showModernDateRangePicker(
                                context: context,
                                configuration: widget.configuration,
                                initialDateRange: DateTimeRange(
                                  start: start,
                                  end: end,
                                ),
                              );

                          if (pickedRange != null) {
                            setState(() {
                              condition.type = OmFilterConditionType.between;
                              condition.value = pickedRange.start
                                  .toIso8601String();
                              condition.valueTo = pickedRange.end
                                  .toIso8601String();

                              final dateFormat =
                                  widget.columnModel.customDateFormat ??
                                  'yyyy-MM-dd';
                              controller.text = DateFormat(
                                dateFormat,
                              ).format(pickedRange.start);
                              controllerTo.text = DateFormat(
                                dateFormat,
                              ).format(pickedRange.end);
                            });
                            widget.onApply();
                          }
                        } else if (widget.columnModel.type ==
                            OmGridRowTypeEnum.time) {
                          TimeOfDay? pickedTime =
                              await GridDatePickerUtils.showModernTimePicker(
                                context: context,
                                configuration: widget.configuration,
                              );
                          if (pickedTime != null) {
                            final now = DateTime.now();
                            final dt = DateTime(
                              now.year,
                              now.month,
                              now.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                            String displayVal = DateFormat(
                              widget.columnModel.customDateFormat ?? 'HH:mm',
                            ).format(dt);

                            controllerTo.text = displayVal;
                            condition.valueTo = displayVal;
                            widget.onApply();
                          }
                        }
                      },
                      style: const TextStyle(fontSize: 13),
                      onChanged: (val) {
                        condition.valueTo = val;
                        widget.onApply();
                      },
                      decoration: InputDecoration(
                        hintText: "To...",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          size: 16,
                          color: Colors.grey.shade400,
                        ),
                        contentPadding: const EdgeInsets.only(top: 4),
                        border: InputBorder.none,
                        suffixIcon: controllerTo.text.isNotEmpty
                            ? InkWell(
                                onTap: () {
                                  controllerTo.clear();
                                  condition.valueTo = '';
                                  widget.onApply();
                                },
                                child: const Icon(Icons.clear, size: 16),
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
