import 'package:om_data_grid/src/components/default_button.dart';
import 'package:om_data_grid/src/components/grid_combo_box/grid_combo_box.dart';
import 'package:om_data_grid/src/enums/grid_row_type_enum.dart';
import 'package:om_data_grid/src/models/advanced_filter_model.dart';
import 'package:om_data_grid/src/models/datagrid_configuration.dart';
import 'package:om_data_grid/src/models/grid_column_model.dart';
import 'package:om_data_grid/src/utils/filter_utils.dart';
import 'package:om_data_grid/src/utils/general_helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../grid_substring_highlight.dart';

class GridFilterBody extends StatefulWidget {
  const GridFilterBody({
    super.key,
    required this.orgData,
    required this.dataSource,
    required this.onSearch,
    required this.attributes,
    required this.allAttributes,
    required this.configuration,
    this.globalSearchText,
  });

  final List<dynamic> dataSource;
  final List<dynamic> orgData;
  final OmGridColumnModel attributes;
  final List<OmGridColumnModel> allAttributes;
  final void Function(List<dynamic>) onSearch;
  final OmDataGridConfiguration configuration;
  final String? globalSearchText;

  static void clearSearch({
    OmGridColumnModel? attribute,
    required List<dynamic> orgData,
    required List<OmGridColumnModel> allAttributes,
    required void Function(List<dynamic>) onSearch,
    String? globalSearchText,
  }) {
    _performFilteringWithoutState(
      attribute: attribute,
      orgData: orgData,
      allAttributes: allAttributes,
      onSearch: onSearch,
      globalSearchText: globalSearchText,
    );
  }

  static void _performFilteringWithoutState({
    OmGridColumnModel? attribute,
    required List<dynamic> orgData,
    required List<OmGridColumnModel> allAttributes,
    required void Function(List<dynamic>) onSearch,
    String? globalSearchText,
  }) {
    if (attribute != null) {
      // Clear the attribute's filter
      attribute.filter = false;
      attribute.searchText = '';
      attribute.quickFilterText = null;
      attribute.notSelectedFilterData = [];
      attribute.advancedFilter = null;
      attribute.advancedFilterUI = null;
    }

    // Calculate filtered data
    List<dynamic> filteredData = OmFilterUtils.performFiltering(
      data: orgData,
      allColumns: allAttributes,
      globalSearch: globalSearchText,
    );

    // Call the onSearch callback with the filtered data
    onSearch(filteredData);
  }

  @override
  State<GridFilterBody> createState() => _GridFilterBodyState();
}

class _GridFilterBodyState extends State<GridFilterBody> {
  List<dynamic> dataSource = [];
  List<dynamic> orgData = [];
  late OmGridColumnModel attributes;
  String key = '';
  String keyTwo = '';
  late OmAdvancedFilterModel advancedFilter;
  late TextEditingController _textController1;
  late TextEditingController _textController1To;

  bool? selectAll = true;
  int searchInInput = 0;

  @override
  void initState() {
    attributes = widget.attributes;

    // Restore ONLY the condition type (the GridComboBox state) from advancedFilterUI.
    // The text fields are always initialized as empty strings per request.
    if (attributes.advancedFilterUI != null &&
        attributes.advancedFilterUI!.conditions.isNotEmpty) {
      advancedFilter = OmAdvancedFilterModel(
        conditions: [
          OmFilterCondition(
            type: attributes.advancedFilterUI!.conditions[0].type,
          ),
        ],
      );
    } else {
      advancedFilter = OmAdvancedFilterModel(conditions: [OmFilterCondition()]);
    }

    _textController1 = TextEditingController(text: '');
    _textController1To = TextEditingController(text: '');

    initData();

    super.initState();
  }

  @override
  void dispose() {
    _textController1.dispose();
    _textController1To.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (attributes.type == OmGridRowTypeEnum.comboBox &&
            attributes.comboBoxSettings?.showInput == true)
          CupertinoSlidingSegmentedControl(
            padding: const EdgeInsets.all(5),
            groupValue: searchInInput,
            thumbColor: widget.configuration.primaryColor,
            children: {
              0: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  attributes.comboBoxSettings?.valueKey.toString() ?? "",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: searchInInput == 0
                        ? widget.configuration.primaryForegroundColor
                        : widget.configuration.headerForegroundColor,
                  ),
                ),
              ),
              1: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  attributes.comboBoxSettings?.inputKey.toString() ?? "",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: searchInInput == 1
                        ? widget.configuration.primaryForegroundColor
                        : widget.configuration.headerForegroundColor,
                  ),
                ),
              ),
            },
            onValueChanged: (i) {
              searchInInput = i ?? 0;
              initData();
              setState(() {});
            },
          ),
        if (attributes.type == OmGridRowTypeEnum.comboBox &&
            attributes.comboBoxSettings?.showInput == true)
          const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.attributes.title),
            if (selectAll != true ||
                (widget.attributes.advancedFilter != null &&
                    widget.attributes.advancedFilter!.conditions.any(
                      (c) =>
                          c.value.trim().isNotEmpty ||
                          (c.type == OmFilterConditionType.between &&
                              c.valueTo.trim().isNotEmpty) ||
                          c.type == OmFilterConditionType.empty ||
                          c.type == OmFilterConditionType.notEmpty,
                    )))
              InkWell(
                onTap: () {
                  GridFilterBody.clearSearch(
                    attribute: widget.attributes,
                    orgData: widget.orgData,
                    allAttributes: widget.allAttributes,
                    onSearch: widget.onSearch,
                    globalSearchText: widget.globalSearchText,
                  );
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Clear Filter",
                  style: TextStyle(
                    color: widget.configuration.errorColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        _buildAdvancedFilterUI(),
        const SizedBox(height: 5),
        Column(
          children: [
            GestureDetector(
              onTap: () {
                selectAll = !(selectAll ?? true);
                for (var item in dataSource) {
                  item["select"] = selectAll ?? false;
                  keepTheSelectedItemsWhileSearching(item);
                }
                checkSelectAll();
                setState(() {});
              },
              child: Row(
                children: [
                  Checkbox(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    value: selectAll,
                    activeColor: widget.configuration.primaryColor,
                    checkColor: widget.configuration.primaryForegroundColor,
                    tristate: true,
                    onChanged: (value) {
                      selectAll = value ?? false;
                      for (var item in dataSource) {
                        item["select"] = value ?? false;
                        keepTheSelectedItemsWhileSearching(item);
                      }
                      checkSelectAll();
                      setState(() {});
                    },
                  ),
                  Expanded(
                    child: Text(
                      "Select All",
                      style: TextStyle(
                        color: widget.configuration.rowForegroundColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 5, color: widget.configuration.rowBorderColor),
          ],
        ),
        Expanded(
          child: ListView(
            children: List.generate(dataSource.length, (i) {
              var item = dataSource[i];
              String text = getTextFromValue(item);
              if (text == "null") text = "None";

              List<String> terms = [
                _textController1.text,
                _textController1To.text,
              ].where((t) => t.isNotEmpty).toList();

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: GestureDetector(
                  onTap: () {
                    item["select"] = !(item["select"] ?? true);
                    keepTheSelectedItemsWhileSearching(item);
                    checkSelectAll();
                  },
                  child: Row(
                    children: [
                      Checkbox(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        value: item["select"] ?? false,
                        activeColor: widget.configuration.primaryColor,
                        checkColor: widget.configuration.primaryForegroundColor,
                        onChanged: (value) {
                          item["select"] = value!;
                          keepTheSelectedItemsWhileSearching(item);
                          checkSelectAll();
                        },
                      ),
                      Expanded(
                        child: terms.isEmpty
                            ? Text(
                                text,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color:
                                      widget.configuration.rowForegroundColor,
                                  fontSize: mySize(xs: 16, md: 14),
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            : GridSubstringHighlight(
                                text: text,
                                terms: terms,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textStyle: TextStyle(
                                  color:
                                      widget.configuration.rowForegroundColor,
                                  fontSize: mySize(xs: 16, md: 14),
                                  fontWeight: FontWeight.w400,
                                ),
                                textStyleHighlight: TextStyle(
                                  color:
                                      widget.configuration.rowForegroundColor,
                                  fontSize: mySize(xs: 16, md: 14),
                                  fontWeight: FontWeight.bold,
                                  backgroundColor: widget
                                      .configuration.primaryColor
                                      .withOpacity(0.3),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        Divider(color: widget.configuration.rowBorderColor),
        saveCancelButtons(context),
      ],
    );
  }

  void keepTheSelectedItemsWhileSearching(Map<String, dynamic> item) {
    int orgIndex = orgData.indexWhere(
      (orgItem) => orgItem["value"] == item["value"],
    );
    if (orgIndex != -1) {
      orgData[orgIndex]["select"] = item["select"];
    }
  }

  void initData() {
    key = widget.attributes.key;
    attributes = widget.attributes;

    final List<OmGridColumnModel> columnsForChecklist = widget.allAttributes.map((
      c,
    ) {
      if (c.key == attributes.key) {
        return OmGridColumnModel(
          column: c.column,
          isVisible: c.isVisible,
          filter: false,
          notSelectedFilterData: [],
          searchText: "",
          quickFilterText: null,
          advancedFilter: null,
        );
      }
      return c;
    }).toList();

    final List<dynamic> availableData = OmFilterUtils.performFiltering(
      data: widget.orgData,
      allColumns: columnsForChecklist,
      globalSearch: widget.globalSearchText,
    );

    if (attributes.type == OmGridRowTypeEnum.comboBox &&
        attributes.comboBoxSettings?.multipleSelect == true) {
      if (searchInInput == 1) {
        keyTwo = attributes.comboBoxSettings?.inputKey ?? "";
      } else {
        keyTwo = attributes.comboBoxSettings?.valueKey ?? "";
      }
      List orgValues = [];
      List values = [];
      for (var item in availableData) {
        List myValues = [];
        if (item[key] is List) {
          for (var obj in item[key]) {
            if (obj is OmGridComboBoxItem) {
              orgValues.add(obj.value);
              myValues.add(obj.value);
            } else if (obj is Map && keyTwo.isNotEmpty) {
              orgValues.add(obj[keyTwo].toString());
              myValues.add(obj[keyTwo].toString());
            } else {
              orgValues.add(obj.toString());
              myValues.add(obj.toString());
            }
          }
        }
        item["dropDownValues"] = myValues;
      }

      for (var item in widget.dataSource) {
        if (item[key] is List) {
          for (var obj in item[key]) {
            if (obj is OmGridComboBoxItem) {
              values.add(obj.value);
            } else if (obj is Map && keyTwo.isNotEmpty) {
              values.add(obj[keyTwo].toString());
            } else {
              values.add(obj.toString());
            }
          }
        }
      }
      orgData =
          orgValues.toSet().map((obj) => Map.from({"value": obj})).toList();
      dataSource =
          values.toSet().map((obj) => Map.from({"value": obj})).toList();
    } else {
      orgData = availableData
          .map((obj) => obj[key].toString())
          .toSet()
          .map((obj) => Map.from({"value": obj}))
          .toSet()
          .toList();
      dataSource = widget.dataSource
          .map((obj) => obj[key].toString())
          .toSet()
          .map((obj) => Map.from({"value": obj}))
          .toList();
    }

    List data = orgData.map((map) => Map.from(map)).toList();
    orgData.clear();
    List notSelectedFilterData = attributes.notSelectedFilterData ?? [];
    for (var item in data) {
      int i = notSelectedFilterData.indexWhere(
        (e) => e["value"] == item["value"],
      );

      // We only use notSelectedFilterData to set the select state initially.
      // matchesAdvFilter only controls if it's visible in the dataSource initially.
      if (i > -1) {
        item["select"] = false;
      } else {
        item["select"] = true;
      }
      orgData.add(item);
    }
    dataSource = orgData.map((map) => Map.from(map)).toList();
    _applyAdvancedFilter(initState: true);
    checkSelectAll();
  }

  void _applyAdvancedFilter({bool initState = false}) {
    dataSource.clear();
    for (var item in orgData) {
      bool condition = OmFilterUtils.evaluateAdvancedFilter(
        item["value"],
        advancedFilter,
        attributes,
      );

      if (condition) {
        dataSource.add(item);
      }
    }
    checkSelectAll();
  }

  Widget _buildAdvancedFilterUI() {
    final condition1 = advancedFilter.conditions[0];

    return _buildConditionSection(
      condition1,
      _textController1,
      _textController1To,
      0,
    );
  }

  Widget _buildConditionSection(
    OmFilterCondition condition,
    TextEditingController controller,
    TextEditingController controllerTo,
    int index,
  ) {
    bool isBetween = condition.type == OmFilterConditionType.between;

    return Column(
      children: [
        Container(
          height: 38,
          decoration: BoxDecoration(
            border: Border.all(color: widget.configuration.inputBorderColor),
            borderRadius: BorderRadius.circular(4),
            color: widget.configuration.inputFillColor,
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
            borderColor: Colors.transparent,
            onChange: (val) {
              if (val != null) {
                setState(() {
                  condition.type = OmFilterConditionType.values.firstWhere(
                    (e) => e.toString() == val,
                  );
                });
                _applyAdvancedFilter();
              }
            },
            configuration: widget.configuration,
          ),
        ),
        if (condition.type != OmFilterConditionType.empty &&
            condition.type != OmFilterConditionType.notEmpty) ...[
          const SizedBox(height: 5),
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: widget.configuration.inputFillColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: widget.configuration.inputBorderColor),
            ),
            child: TextField(
              controller: controller,
              readOnly: [
                    OmGridRowTypeEnum.date,
                    OmGridRowTypeEnum.dateTime,
                    OmGridRowTypeEnum.time,
                  ].contains(attributes.type) &&
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
                if (attributes.type == OmGridRowTypeEnum.date ||
                    attributes.type == OmGridRowTypeEnum.dateTime) {
                  if (condition.type == OmFilterConditionType.between) {
                    DateTime start =
                        DateTime.tryParse(condition.value) ?? DateTime.now();
                    DateTime end =
                        DateTime.tryParse(condition.valueTo) ?? DateTime.now();

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
                        condition.value = pickedRange.start.toIso8601String();
                        condition.valueTo = pickedRange.end.toIso8601String();

                        final dateFormat =
                            attributes.customDateFormat ?? 'yyyy-MM-dd';
                        controller.text = DateFormat(
                          dateFormat,
                        ).format(pickedRange.start);
                        controllerTo.text = DateFormat(
                          dateFormat,
                        ).format(pickedRange.end);
                      });
                      _applyAdvancedFilter();
                    }
                  } else {
                    DateTime current =
                        DateTime.tryParse(condition.value) ?? DateTime.now();
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
                            attributes.customDateFormat ?? 'yyyy-MM-dd';
                        controller.text = DateFormat(dateFormat).format(picked);
                      });
                      _applyAdvancedFilter();
                    }
                  }
                } else if (attributes.type == OmGridRowTypeEnum.time) {
                  if (condition.type == OmFilterConditionType.between) {
                    OmTimeRange? picked =
                        await GridDatePickerUtils.showModernTimeRangePicker(
                      context: context,
                      configuration: widget.configuration,
                    );
                    if (picked != null) {
                      final now = DateTime.now();
                      final startDt = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        picked.start.hour,
                        picked.start.minute,
                      );
                      final endDt = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        picked.end.hour,
                        picked.end.minute,
                      );
                      final dateFormat = attributes.customDateFormat ?? 'HH:mm';
                      controller.text = DateFormat(dateFormat).format(startDt);
                      controllerTo.text = DateFormat(dateFormat).format(endDt);
                      condition.value = DateFormat('HH:mm').format(startDt);
                      condition.valueTo = DateFormat('HH:mm').format(endDt);
                      _applyAdvancedFilter();
                    }
                  } else {
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
                        attributes.customDateFormat ?? 'HH:mm',
                      ).format(dt);

                      controller.text = displayVal;
                      condition.value = displayVal;
                      _applyAdvancedFilter();
                    }
                  }
                }
              },
              style: const TextStyle(fontSize: 13),
              onChanged: (val) {
                condition.value = val;
                _applyAdvancedFilter();
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: isBetween ? "From..." : "Filter...",
                hintStyle: TextStyle(
                  color: widget.configuration.secondaryTextColor,
                  fontSize: 13,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 16,
                  color: widget.configuration.secondaryTextColor,
                ),
                contentPadding: const EdgeInsets.only(top: 12),
                border: InputBorder.none,
                isDense: true,
                suffixIcon: controller.text.isNotEmpty
                    ? InkWell(
                        onTap: () {
                          controller.clear();
                          condition.value = '';
                          _applyAdvancedFilter();
                          setState(() {});
                        },
                        child: const Icon(Icons.clear, size: 16),
                      )
                    : null,
              ),
            ),
          ),
          if (isBetween) ...[
            const SizedBox(height: 5),
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: widget.configuration.inputFillColor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: widget.configuration.inputBorderColor,
                ),
              ),
              child: TextField(
                controller: controllerTo,
                readOnly: [
                      OmGridRowTypeEnum.date,
                      OmGridRowTypeEnum.dateTime,
                      OmGridRowTypeEnum.time,
                    ].contains(attributes.type) &&
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
                  // Between logic for "To" field is usually handled in the same picker as "From" for RangePickers
                  // but we handle time picker separately if needed
                  if (attributes.type == OmGridRowTypeEnum.time &&
                      condition.type == OmFilterConditionType.between) {
                    OmTimeRange? picked =
                        await GridDatePickerUtils.showModernTimeRangePicker(
                      context: context,
                      configuration: widget.configuration,
                    );
                    if (picked != null) {
                      final now = DateTime.now();
                      final startDt = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        picked.start.hour,
                        picked.start.minute,
                      );
                      final endDt = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        picked.end.hour,
                        picked.end.minute,
                      );
                      final dateFormat = attributes.customDateFormat ?? 'HH:mm';
                      controller.text = DateFormat(dateFormat).format(startDt);
                      controllerTo.text = DateFormat(dateFormat).format(endDt);
                      condition.value = DateFormat('HH:mm').format(startDt);
                      condition.valueTo = DateFormat('HH:mm').format(endDt);
                      _applyAdvancedFilter();
                    }
                  }
                },
                style: const TextStyle(fontSize: 13),
                onChanged: (val) {
                  condition.valueTo = val;
                  _applyAdvancedFilter();
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: "To...",
                  hintStyle: TextStyle(
                    color: widget.configuration.secondaryTextColor,
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 16,
                    color: widget.configuration.secondaryTextColor,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(top: 12),
                  isDense: true,
                  suffixIcon: controllerTo.text.isNotEmpty
                      ? InkWell(
                          onTap: () {
                            controllerTo.clear();
                            condition.valueTo = '';
                            _applyAdvancedFilter();
                            setState(() {});
                          },
                          child: const Icon(Icons.clear, size: 16),
                        )
                      : null,
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }

  void checkSelectAll() {
    int i;
    i = dataSource.indexWhere((e) => e["select"] == false);
    // check if have unselected items
    if (i > -1) {
      i = dataSource.indexWhere((e) => e["select"] == true);
      // check if all items is unselected or not
      if (i > -1) {
        selectAll = null;
      } else {
        selectAll = false;
      }
    }
    // check if all items is selected
    else {
      selectAll = true;
    }
    setState(() {});
  }

  String getTextFromValue(Map<String, dynamic> item) {
    return OmFilterUtils.getDisplayValue(item["value"], attributes);
  }

  SizedBox saveCancelButtons(BuildContext context) {
    return SizedBox(
      height: mySize(xs: 50, md: 40),
      child: Row(
        children: [
          Expanded(
            child: OmDefaultButton(
              fontsize: 14,
              text: "Search",
              configuration: widget.configuration,
              press: () {
                attributes.notSelectedFilterData = [];

                // 1. Identify if a search/advanced condition is active in the popup
                bool hasFilterText = advancedFilter.conditions.any((c) {
                  if (c.type == OmFilterConditionType.empty ||
                      c.type == OmFilterConditionType.notEmpty) {
                    return true;
                  }
                  if (c.type == OmFilterConditionType.between) {
                    return c.value.isNotEmpty || c.valueTo.isNotEmpty;
                  }
                  return c.value.isNotEmpty;
                });

                // 2. "The Old Way" Logic:
                // If search is active and everything visible is selected (selectAll == true or null),
                // we treat the search as a "filter" by unchecking anything that doesn't match.
                // This satisfies the "it filtering on values" requirement.
                //
                // BUT, if the user explicitly clicked "Deselect All" while searching (selectAll == false),
                // we DO NOT touch the hidden items. This satisfies the "don't empty the grid" requirement
                // because those hidden items will remain checked and stay visible in the grid.
                if (hasFilterText && selectAll != false) {
                  for (var item in orgData) {
                    bool matches = OmFilterUtils.evaluateAdvancedFilter(
                      item["value"],
                      advancedFilter,
                      attributes,
                    );
                    if (!matches) {
                      item["select"] = false;
                    }
                  }
                }

                // 3. Clear advancedFilter for the grid itself to avoid "AND" conflict.
                // The checklist (notSelectedFilterData) becomes the source of truth for the grid.
                attributes.advancedFilter = null;

                // 4. Preserve ONLY the condition type UI (GridComboBox state) for next time.
                // Text fields (attributes.searchText) are kept clean as requested.
                attributes.advancedFilterUI = advancedFilter;
                attributes.searchText = '';

                // 5. Collect unchecked items for exclusion
                for (var item in orgData) {
                  if (item["select"] == false) {
                    attributes.notSelectedFilterData!.add(item);
                  }
                }

                // 6. Update filter icon visibility
                attributes.filter = attributes.notSelectedFilterData != null &&
                    attributes.notSelectedFilterData!.isNotEmpty;

                List data = OmFilterUtils.performFiltering(
                  data: widget.orgData,
                  allColumns: widget.allAttributes,
                  globalSearch: widget.globalSearchText,
                );
                widget.onSearch(data);
                Navigator.of(context).pop();
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OmDefaultButton(
              fontsize: 14,
              text: "Cancel",
              press: () {
                Navigator.of(context).pop();
              },
              borderColor: widget.configuration.rowBorderColor,
              forecolor: widget.configuration.rowForegroundColor,
              backcolor: widget.configuration.inputFillColor,
            ),
          ),
        ],
      ),
    );
  }
}
