import 'package:om_data_grid/src/components/custom_bottom_sheet.dart';
import 'package:om_data_grid/src/components/grid_combo_box/grid_combo_box_multi_headers.dart';
import 'package:om_data_grid/src/models/datagrid_configuration.dart';
import 'package:om_data_grid/src/models/grid_combo_box_item.dart';
import 'package:om_data_grid/src/models/grid_header_model.dart';
import 'package:om_data_grid/src/utils/general_helpers.dart';
import 'package:om_data_grid/src/utils/platform_helper.dart'
    show OmPlatformHelper;
import 'package:om_data_grid/src/utils/scroll_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../grid_substring_highlight.dart';

class GridComboBox extends FormField<String> {
  final String? value;
  GridComboBox({
    super.key,
    this.value,
    List<OmGridComboBoxItem> selectedItems = const [],
    required List<OmGridComboBoxItem> items,
    bool enabled = true,
    bool multipleSelect = false,
    String? initialValue,
    String? initialText,
    String? labelText = "",
    Widget? icon,
    bool enableSearch = false,
    bool isNumericType = true,
    bool showInput = false,
    String? inputLabel,
    String? defaultInputValue,
    bool loading = false,
    void Function(dynamic value)? onChange,
    void Function(dynamic value)? onTouchOutSide,
    super.validator,
    super.onSaved,
    super.autovalidateMode = AutovalidateMode.disabled,
    double? borderRadius,
    Color? borderColor,
    Color? searchFieldFillColor,
    Color? searchFieldBorderColor,
    double? itemFontSize,
    double? itemBorderRadius,
    double? fontSize,
    Color? multiSelectChipColor,
    Color? backgroundColor,
    EdgeInsetsGeometry? contentPadding,
    TextAlign textAlign = TextAlign.start,
    bool autoOpen = false,
    String? hintText,
    Future<OmGridComboBoxItem?> Function()? onAddNewItem,
    FocusNode? focusNode,
    double? overlayWidth,
    List<OmComboBoxHeaderModel> headers = const [],
    double height = 50,
    bool showClearButton = true,
    OmDataGridConfiguration? configuration,
  }) : super(
         initialValue: value ?? initialValue,
         builder: (FormFieldState<String> field) {
           final _ComboBoxFormFieldState state =
               field as _ComboBoxFormFieldState;
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               _ComboBoxInput(
                 state: state,
                 selectedItems: selectedItems,
                 items: items,
                 enabled: enabled,
                 multipleSelect: multipleSelect,
                 initialText: initialText,
                 labelText: labelText,
                 icon: icon,
                 enableSearch: enableSearch,
                 isNumericType: isNumericType,
                 showInput: showInput,
                 inputLabel: inputLabel,
                 defaultInputValue: defaultInputValue,
                 loading: loading,
                 onChange: (value) {
                   field.didChange(value);
                   if (onChange != null) onChange(value);
                 },
                 onTouchOutSide: onTouchOutSide,
                 borderRadius: borderRadius,
                 borderColor: borderColor,
                 searchFieldFillColor: searchFieldFillColor,
                 searchFieldBorderColor: searchFieldBorderColor,
                 itemFontSize: itemFontSize,
                 itemBorderRadius: itemBorderRadius,
                 fontSize: fontSize,
                 multiSelectChipColor: multiSelectChipColor,
                 backgroundColor: backgroundColor,
                 contentPadding: contentPadding,
                 textAlign: textAlign,
                 autoOpen: autoOpen,
                 hintText: hintText,
                 onAddNewItem: onAddNewItem,
                 focusNode: focusNode,
                 overlayWidth: overlayWidth,
                 headers: headers,
                 height: height,
                 showClearButton: showClearButton,
                 configuration: configuration,
               ),
               if (state.hasError)
                 Padding(
                   padding: const EdgeInsetsDirectional.only(start: 20, top: 4),
                   child: Text(
                     state.errorText!,
                     style: TextStyle(
                       color:
                           configuration?.errorColor ?? const Color(0xFFF44336),
                       fontSize: 10,
                       fontWeight: FontWeight.w400,
                     ),
                   ),
                 ),
             ],
           );
         },
       );

  @override
  FormFieldState<String> createState() => _ComboBoxFormFieldState();
}

class _ComboBoxFormFieldState extends FormFieldState<String> {
  @override
  void didUpdateWidget(GridComboBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentWidget = widget as GridComboBox;
    // If the external value changed OR it differs from internal state, sync it.
    if (currentWidget.value != oldWidget.value ||
        (currentWidget.value != null && currentWidget.value != value)) {
      didChange(currentWidget.value);
    }
  }
}

class _ComboBoxInput extends StatefulWidget {
  final _ComboBoxFormFieldState state;
  final List<OmGridComboBoxItem> selectedItems;
  final List<OmGridComboBoxItem> items;
  final bool multipleSelect;
  final bool enableSearch;
  final String? initialText;
  final String? labelText;
  final Widget? icon;
  final bool enabled;
  final bool isNumericType;
  final bool showInput;
  final String? defaultInputValue;
  final String? inputLabel;
  final bool loading;
  final void Function(dynamic value)? onChange;
  final void Function(dynamic value)? onTouchOutSide;
  final double? borderRadius;
  final Color? borderColor;
  final Color? searchFieldFillColor;
  final Color? searchFieldBorderColor;
  final double? itemFontSize;
  final double? itemBorderRadius;
  final double? fontSize;
  final Color? multiSelectChipColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? contentPadding;
  final TextAlign textAlign;
  final bool autoOpen;
  final String? hintText;
  final Future<OmGridComboBoxItem?> Function()? onAddNewItem;
  final FocusNode? focusNode;
  final double? overlayWidth;
  final List<OmComboBoxHeaderModel> headers;
  final double height;
  final bool showClearButton;
  final OmDataGridConfiguration? configuration;

  const _ComboBoxInput({
    required this.state,
    required this.selectedItems,
    required this.items,
    required this.enabled,
    required this.multipleSelect,
    this.initialText,
    this.labelText,
    this.icon,
    required this.enableSearch,
    required this.isNumericType,
    required this.showInput,
    this.inputLabel,
    this.defaultInputValue,
    required this.loading,
    this.onChange,
    this.onTouchOutSide,
    this.borderRadius,
    this.borderColor,
    this.searchFieldFillColor,
    this.searchFieldBorderColor,
    this.itemFontSize,
    this.fontSize,
    this.itemBorderRadius,
    this.multiSelectChipColor,
    this.backgroundColor,
    this.contentPadding,
    required this.textAlign,
    this.autoOpen = false,
    this.hintText,
    this.onAddNewItem,
    this.focusNode,
    this.overlayWidth,
    required this.headers,
    this.height = 50,
    this.showClearButton = true,
    this.configuration,
  });

  @override
  State<_ComboBoxInput> createState() => _ComboBoxInputState();
}

class _ComboBoxInputState extends State<_ComboBoxInput> {
  TextEditingController searchController = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  final FocusNode _searchFocusNode = FocusNode();
  bool isOpen = false;
  OverlayEntry? _overlayEntry;

  String? myValue;
  String? myText;
  Color? myColor;
  late RegExp regExp;
  List<String> mySelectedItems = [];
  List<OmGridComboBoxItem> selectedItems = [];
  List<OmGridComboBoxItem> orgData = [];
  List<OmGridComboBoxItem> dataSource = [];
  int selectedIndex = -1;
  final ScrollController _scrollController = ScrollController();
  final itemHeight = 50.0;
  late FocusNode _focusNode;

  @override
  void initState() {
    _focusNode = widget.focusNode ?? FocusNode();
    super.initState();
    initData();
    _focusNode.addListener(_onFocusChange);
    if (widget.autoOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _toggleDropdown();
      });
    }
  }

  @override
  void didUpdateWidget(covariant _ComboBoxInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.value != oldWidget.state.value) {
      if (widget.multipleSelect) {
        _updateSelectedItemsFromValue();
      } else {
        getValue();
      }
    }
    if (widget.items != oldWidget.items ||
        widget.selectedItems != oldWidget.selectedItems) {
      initData();
    }
  }

  void _updateSelectedItemsFromValue() {
    myValue = widget.state.value;
    if (myValue == null || myValue!.isEmpty) {
      selectedItems = [];
      mySelectedItems = [];
      return;
    }
    List<String> values = myValue!.split(',');
    selectedItems = [];
    mySelectedItems = [];
    for (var val in values) {
      int idx = orgData.indexWhere(
        (element) => element.value.toString() == val.trim(),
      );
      if (idx != -1) {
        selectedItems.add(orgData[idx]);
        mySelectedItems.add(orgData[idx].text);
      }
    }
  }

  @override
  void dispose() {
    _hideOverlay();
    _scrollController.dispose();
    // _focusNode.dispose();
    _searchFocusNode.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (HardwareKeyboard.instance.isShiftPressed) {
      _hideOverlay();
      return;
    }
  }

  void initData() {
    orgData = widget.items
        .map(
          (e) => OmGridComboBoxItem(
            value: e.value,
            text: e.text,
            color: e.color,
            input: e.input,
            extraData: e.extraData,
          ),
        )
        .toList();
    dataSource = orgData
        .map(
          (e) => OmGridComboBoxItem(
            value: e.value,
            text: e.text,
            color: e.color,
            input: e.input,
            extraData: e.extraData,
          ),
        )
        .toList();
    getValue();
    if (widget.multipleSelect) {
      if (widget.state.value != null && widget.state.value!.isNotEmpty) {
        _updateSelectedItemsFromValue();
      } else {
        selectedItems = widget.selectedItems
            .map(
              (e) => OmGridComboBoxItem(
                value: e.value,
                text: e.text,
                color: e.color,
                input: e.input,
                extraData: e.extraData,
              ),
            )
            .toList();
        mySelectedItems = [];
        if (widget.initialText != null) {
          mySelectedItems.addAll(widget.initialText!.split(','));
        }
      }
    }
    regExp = _getRegExp(widget.isNumericType);
  }

  void getValue() {
    selectedIndex = -1;
    myValue = widget.state.value;
    int i = dataSource.indexWhere(
      (element) => element.value.toString() == myValue.toString(),
    );
    if (i != -1) {
      selectedIndex = i;
      myText = dataSource[i].text;
      myColor = dataSource[i].color;
    } else {
      selectedIndex = -1;
      myText = null;
      myColor = null;
    }
  }

  RegExp _getRegExp(bool isNumericKeyBoard) {
    return isNumericKeyBoard ? RegExp('[0-9.]') : RegExp('.');
  }

  void _toggleDropdown() {
    if (MediaQuery.of(context).size.width <= 768) {
      getValue();
      _showBottomSheet();
    } else {
      if (isOpen) {
        _hideOverlay();
      } else {
        if (mounted) {
          setState(() {
            isOpen = true;
          });
        }
        getValue();
        _showOverlay();
      }
    }
  }

  double _calculateItemsHeight(
    BuildContext context,
    List<OmGridComboBoxItem> items,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;
    double height = (items.length * itemHeight).clamp(0.0, screenHeight * 0.4);

    if (height < screenHeight * 0.4 && widget.enableSearch) {
      height += 75;
    }
    if (height < screenHeight * 0.4 && widget.headers.length > 1) {
      height += 60;
    }
    if (height < screenHeight * 0.4 && widget.onAddNewItem != null) {
      height += 41;
    }

    return height;
  }

  void _updateOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _showOverlay() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final screenHeight = MediaQuery.of(context).size.height;
    final offset = renderBox.localToGlobal(Offset.zero);
    final spaceBelow = screenHeight - (offset.dy + size.height);
    final openAbove = spaceBelow < screenHeight * 0.4;

    // Request focus with a slight delay to ensure UI is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      if (!widget.multipleSelect) {
        _scrollToSelectedItem();
      }
      if (widget.autoOpen) _searchFocusNode.requestFocus();
    });

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final itemsHeight = _calculateItemsHeight(context, dataSource);

        return Stack(
          children: [
            // Add a transparent layer to capture taps outside the dropdown
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _hideOverlay();
                },
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              width: widget.overlayWidth ?? size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(
                  // If overlay width is wider than the button, shift left so it fits on screen
                  (widget.overlayWidth != null &&
                          widget.overlayWidth! > size.width)
                      ? -(widget.overlayWidth! - size.width).clamp(
                          0.0,
                          MediaQuery.of(context).size.width - size.width,
                        )
                      : 0,
                  openAbove ? -itemsHeight : size.height,
                ),
                child: Material(
                  elevation: 4.0,
                  color:
                      widget.configuration?.gridBackgroundColor ?? Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: itemsHeight,
                    width: size.width,
                    child: itemsWidget(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _showBottomSheet() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.multipleSelect) {
        _scrollToSelectedItem();
      }
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          widget.configuration?.gridBackgroundColor ?? Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => OmCustomBottomSheet(
        configuration: widget.configuration,
        child: itemsWidget(),
      ),
    ).then((_) {
      isOpen = false;
      widget.onTouchOutSide?.call(selectedItems);
      searchController.clear();
      widget.state.validate();
      searchMethod("");
    });
  }

  StatefulBuilder itemsWidget() {
    return StatefulBuilder(
      builder: (context, setState) {
        double itemsHeight = (dataSource.length * itemHeight).clamp(
          0.0,
          1.sh * 0.4,
        );

        if (itemsHeight < 1.sh * 0.4 && widget.enableSearch) {
          itemsHeight += 75;
        }
        if (itemsHeight < 1.sh * 0.4 && widget.headers.length > 1) {
          itemsHeight += 40;
        }
        if (itemsHeight < 1.sh * 0.4 && widget.onAddNewItem != null) {
          itemsHeight += 41;
        }
        return Theme(
          data: ThemeData(
            disabledColor:
                (widget.configuration?.secondaryTextColor ??
                        const Color(0xFF6B6B6B))
                    .withOpacityNew(0.3),
            primaryColor:
                widget.configuration?.primaryColor ?? const Color(0xFF2196F3),
            hintColor:
                (widget.configuration?.secondaryTextColor ??
                        const Color(0xFF6B6B6B))
                    .withOpacityNew(0.6),
            canvasColor:
                widget.configuration?.gridBackgroundColor ?? Colors.white,
            scaffoldBackgroundColor:
                widget.configuration?.gridBackgroundColor ?? Colors.white,
          ),
          child: SizedBox(
            height: itemsHeight,
            child: Focus(
              focusNode: _focusNode,
              onKeyEvent: (FocusNode node, KeyEvent keyEvent) {
                if (keyEvent is KeyDownEvent || keyEvent is KeyRepeatEvent) {
                  if (keyEvent.logicalKey == LogicalKeyboardKey.arrowDown) {
                    if (mounted) {
                      setState(() {
                        selectedIndex += 1;
                        if (selectedIndex >= dataSource.length) {
                          selectedIndex = dataSource.length - 1;
                        }
                        _scrollToSelectedItem();
                      });
                    }
                    return KeyEventResult.handled;
                  } else if (keyEvent.logicalKey ==
                      LogicalKeyboardKey.arrowUp) {
                    if (mounted) {
                      setState(() {
                        selectedIndex -= 1;
                        if (selectedIndex < 0) selectedIndex = 0;
                        _scrollToSelectedItem();
                      });
                    }
                    return KeyEventResult.handled;
                  } else if (keyEvent.logicalKey == LogicalKeyboardKey.enter) {
                    if (selectedIndex == -1 || dataSource.isEmpty) {
                      return KeyEventResult.ignored;
                    }
                    if (widget.multipleSelect) {
                      int selectedIdx = selectedItems.indexWhere(
                        (element) =>
                            element.value == dataSource[selectedIndex].value,
                      );
                      if (selectedIdx != -1) {
                        selectedItems.removeAt(selectedIdx);
                        mySelectedItems.removeAt(selectedIdx);
                      } else {
                        selectedItems.add(dataSource[selectedIndex]);
                        mySelectedItems.add(dataSource[selectedIndex].text);
                      }
                      widget.state.didChange(
                        selectedItems.map((e) => e.value).join(','),
                      );
                      if (mounted) setState(() {});
                    } else {
                      myText = dataSource[selectedIndex].text;
                      myColor = dataSource[selectedIndex].color;
                      myValue = dataSource[selectedIndex].value;
                      widget.state.didChange(myValue);
                      if (widget.onChange != null) {
                        widget.onChange!(myValue);
                      }
                      _hideOverlay();
                    }
                    return KeyEventResult.handled;
                  } else if (keyEvent.logicalKey == LogicalKeyboardKey.escape) {
                    _hideOverlay();
                    return KeyEventResult.handled;
                  } else if (keyEvent.logicalKey == LogicalKeyboardKey.tab) {
                    _hideOverlay();
                    // Don't handle the event, let it propagate naturally
                    return KeyEventResult.ignored;
                  }
                }
                return KeyEventResult.ignored;
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.onAddNewItem != null) ...[
                    InkWell(
                      onTap: () async {
                        _hideOverlay();
                        OmGridComboBoxItem? newItem =
                            await widget.onAddNewItem!();
                        if (newItem == null) return;
                        dataSource.add(newItem);
                        orgData.add(newItem);
                        myText = newItem.text;
                        myColor = newItem.color;
                        myValue = newItem.value;
                        widget.state.didChange(myValue);
                        widget.onChange?.call(myValue);
                        if (context.mounted) setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add,
                              color:
                                  widget.configuration?.primaryColor ??
                                  const Color(0xFF2196F3),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "add-new-item",
                              style: TextStyle(
                                color:
                                    widget.configuration?.primaryColor ??
                                    const Color(0xFF2196F3),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      color:
                          (widget.configuration?.secondaryTextColor ??
                                  const Color(0xFF6B6B6B))
                              .withOpacityNew(0.1),
                      height: 0.5,
                    ),
                  ],
                  if (widget.enableSearch)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          fillColor:
                              widget.configuration?.inputFillColor ??
                              const Color(0xFFF5F5F5),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                              color:
                                  widget.configuration?.inputFocusBorderColor ??
                                  widget.configuration?.primaryColor ??
                                  const Color(0xFF2196F3),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                              color:
                                  widget.configuration?.inputBorderColor ??
                                  const Color(0xFFE0E0E0),
                              width: 1,
                            ),
                          ),
                          hintStyle: TextStyle(fontSize: 14),
                          suffixIcon: searchController.text.isEmpty
                              ? Icon(
                                  Iconsax.search_normal_1_copy,
                                  color:
                                      widget
                                          .configuration
                                          ?.secondaryTextColor ??
                                      const Color(0xFF6B6B6B),
                                  size: 20,
                                )
                              : IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color:
                                        widget.configuration?.errorColor ??
                                        const Color(0xFFF44336),
                                  ),
                                  onPressed: () {
                                    searchController.clear();
                                    if (mounted) {
                                      setState(() {
                                        searchMethod("");
                                      });
                                    }
                                  },
                                ),
                          hintText: 'Search...',
                        ),
                        onChanged: (value) {
                          if (mounted) {
                            setState(() {
                              searchMethod(value);
                            });
                          }
                        },
                      ),
                    ),
                  if (widget.headers.length > 1)
                    GridComboxBoxMultiColumnsHeaders(
                      headers: widget.headers,
                      multi: widget.multipleSelect,
                      configuration: widget.configuration!,
                    ),
                  Flexible(
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: dataSource.length,
                      separatorBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          child: Divider(
                            color:
                                (widget.configuration?.secondaryTextColor ??
                                        const Color(0xFF6B6B6B))
                                    .withOpacityNew(0.1),
                            height: 0.5,
                          ),
                        );
                      },
                      itemBuilder: (context, index) {
                        return widget.multipleSelect
                            ? multiDropDownItem(index, setState)
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: singleDropDownItem(index),
                              );
                      },
                    ),
                  ),
                  if (itemsHeight > 1.sh * 0.4) const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _scrollToSelectedItem() {
    OmScrollHelper().scrollToSelectedItem(
      scrollController: _scrollController,
      selectedIndex: selectedIndex,
      itemHeight: itemHeight,
    );
  }

  void searchMethod(String value) {
    if (value.isEmpty) {
      dataSource = orgData
          .map(
            (e) => OmGridComboBoxItem(
              value: e.value,
              text: e.text,
              color: e.color,
              input: e.input,
              extraData: e.extraData,
            ),
          )
          .toList();
    } else {
      if (widget.headers.length > 1) {
        dataSource = orgData
            .where((item) {
              final Map<String, dynamic> itemData = item.extraData;

              return widget.headers.any((header) {
                final headerValue = itemData[header.key] ?? '';
                return headerValue.toString().toLowerCase().contains(
                  value.toString().toLowerCase(),
                );
              });
            })
            .map(
              (e) => OmGridComboBoxItem(
                value: e.value,
                text: e.text,
                color: e.color,
                input: e.input,
                extraData: e.extraData,
              ),
            )
            .toList();
      } else {
        dataSource = orgData
            .where(
              (item) => item.text.toLowerCase().contains(value.toLowerCase()),
            )
            .map(
              (e) => OmGridComboBoxItem(
                value: e.value,
                text: e.text,
                color: e.color,
                input: e.input,
                extraData: e.extraData,
              ),
            )
            .toList();
      }
    }

    // Update the overlay after search results change
    _updateOverlay();
  }

  void _hideOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }

    // Cancel any pending focus requests
    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus(
      disposition: UnfocusDisposition.scope,
    );

    // Force focus traversal to the next element
    Future.microtask(() {
      if (!mounted) return;
      isOpen = false;
      widget.onTouchOutSide?.call(selectedItems);
      if (!widget.autoOpen) searchController.clear();
      widget.state.validate();
      searchMethod("");
      // This helps ensure focus traversal moves to the next element
      if (widget.autoOpen) FocusScope.of(context).nextFocus();
    });
  }

  Widget singleDropDownItem(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () {
          if (mounted) {
            setState(() {
              myText = dataSource[index].text;
              myColor = dataSource[index].color;
              myValue = dataSource[index].value;
              // Trigger form validation
              widget.state.didChange(myValue);
              widget.onChange?.call(myValue);
            });
          }
          if (OmPlatformHelper.isDesktop == false) {
            isOpen = false;
            Navigator.of(context).pop();
          } else {
            _hideOverlay();
          }
        },
        child: widget.headers.length > 1
            ? ComboxBoxMultiColumnsRows(
                item: dataSource[index],
                headers: widget.headers,
                searchController: searchController,
                selected: selectedIndex == index,
                configuration: widget.configuration!,
              )
            : Container(
                decoration: BoxDecoration(
                  color: selectedIndex == index
                      ? (widget.configuration?.primaryColor ??
                                const Color(0xFF2196F3))
                            .withOpacityNew(0.1)
                      : null,
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsetsDirectional.only(
                  end: 8,
                  top: 8,
                  bottom: 8,
                  start: 2,
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 4,
                      height: selectedIndex == index ? 18 : 0,
                      decoration: BoxDecoration(
                        color:
                            widget.configuration?.primaryColor ??
                            const Color(0xFF2196F3),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: searchController.text.isEmpty
                          ? Text(
                              dataSource[index].text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: widget.itemFontSize ?? 16,
                                color: dataSource[index].color,
                              ),
                            )
                          : GridSubstringHighlight(
                              text: dataSource[index].text,
                              term: searchController.text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textStyle: TextStyle(
                                fontSize: widget.itemFontSize ?? 16,
                                color: dataSource[index].color,
                              ),
                              textStyleHighlight: TextStyle(
                                fontSize: widget.itemFontSize ?? 16,
                                color: dataSource[index].color,
                                fontWeight: FontWeight.bold,
                                backgroundColor:
                                    (widget.configuration?.primaryColor ??
                                            const Color(0xFF2196F3))
                                        .withOpacity(0.3),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget multiDropDownItem(int index, StateSetter setState) {
    TextEditingController myinput = TextEditingController();
    int currentIndex = selectedItems.indexWhere(
      (element) => element.value == dataSource[index].value,
    );

    if (currentIndex > -1) {
      myinput.text = selectedItems[currentIndex].input ?? "";
    } else {
      myinput.text = dataSource[index].input ?? "";
    }

    bool isSelected = currentIndex != -1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 50,
      child: Container(
        decoration: BoxDecoration(
          color: selectedIndex == index
              ? (widget.configuration?.primaryColor ?? const Color(0xFF2196F3))
                    .withOpacityNew(0.1)
              : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  if (mounted) {
                    setState(() {
                      if (isSelected) {
                        selectedItems.removeAt(currentIndex);
                        mySelectedItems.removeAt(currentIndex);
                      } else {
                        selectedItems.add(dataSource[index]);
                        mySelectedItems.add(dataSource[index].text);
                      }

                      // Trigger form validation for multiple select
                      widget.state.didChange(
                        selectedItems.map((e) => e.value).join(','),
                      );
                    });
                  }
                  // widget.onTouchOutSide?.call(selectedItems);
                  if (selectedItems.isEmpty) {
                    myText = "";
                  }
                  if (mounted) this.setState(() {});
                },
                child: Row(
                  children: [
                    Checkbox(
                      value: isSelected,
                      activeColor:
                          widget.configuration?.primaryColor ??
                          const Color(0xFF2196F3),
                      onChanged: (bool? value) {
                        if (mounted) {
                          setState(() {
                            if (isSelected) {
                              selectedItems.removeAt(currentIndex);
                              mySelectedItems.removeAt(currentIndex);
                            } else {
                              selectedItems.add(dataSource[index]);
                              mySelectedItems.add(dataSource[index].text);
                            }

                            // Trigger form validation for multiple select
                            widget.state.didChange(
                              selectedItems.map((e) => e.value).join(','),
                            );
                          });
                        }
                        if (mounted) this.setState(() {});
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: searchController.text.isEmpty
                          ? Text(
                              dataSource[index].text,
                              style: TextStyle(
                                fontSize: widget.itemFontSize ?? 14,
                                color:
                                    dataSource[index].color ??
                                    widget.configuration?.secondaryTextColor ??
                                    const Color(0xFF6B6B6B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            )
                          : GridSubstringHighlight(
                              text: dataSource[index].text,
                              term: searchController.text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textStyle: TextStyle(
                                fontSize: widget.itemFontSize ?? 14,
                                color:
                                    dataSource[index].color ??
                                    widget.configuration?.secondaryTextColor ??
                                    const Color(0xFF6B6B6B),
                              ),
                              textStyleHighlight: TextStyle(
                                fontSize: widget.itemFontSize ?? 14,
                                color:
                                    dataSource[index].color ??
                                    widget.configuration?.secondaryTextColor ??
                                    const Color(0xFF6B6B6B),
                                fontWeight: FontWeight.bold,
                                backgroundColor:
                                    (widget.configuration?.primaryColor ??
                                            const Color(0xFF2196F3))
                                        .withOpacity(0.3),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.showInput) ...[
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: TextFormField(
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor:
                        widget.configuration?.inputFillColor ??
                        const Color(0xFFF5F5F5),
                    labelText: widget.inputLabel,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color:
                            widget.borderColor ??
                            widget.configuration?.inputBorderColor ??
                            const Color(0xFFE0E0E0),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color:
                            widget.configuration?.inputFocusBorderColor ??
                            widget.configuration?.primaryColor ??
                            const Color(0xFF2196F3),
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  initialValue: myinput.text,
                  inputFormatters: [FilteringTextInputFormatter.allow(regExp)],
                  onChanged: (value) {
                    if (value.isEmpty) {
                      myinput.text = widget.defaultInputValue ?? "";
                      dataSource[index].input = widget.defaultInputValue ?? "";
                    } else {
                      if (currentIndex > -1) {
                        selectedItems[currentIndex].input = value;
                      } else {
                        dataSource[index].input = value;
                      }
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return dropDownButton(context, "loading...");
    }
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: widget.enabled ? _toggleDropdown : null,
        child: dropDownButton(context, myText ?? widget.initialText ?? ""),
      ),
    );
  }

  Widget dropDownButton(BuildContext context, String text) {
    return Container(
      height: widget.height,
      padding:
          widget.contentPadding ?? const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color:
            widget.backgroundColor ??
            widget.configuration?.inputFillColor ??
            const Color(0xFFF5F5F5),
        border: Border.all(
          color: widget.state.hasError
              ? (widget.configuration?.errorColor ?? const Color(0xFFF44336))
              : widget.borderColor ??
                    widget.configuration?.inputBorderColor ??
                    const Color(0xFFE0E0E0),
          width: mySize(xs: 0.5, lg: 0),
        ),
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 6),
      ),
      child: Row(
        children: [
          if (widget.icon != null) ...[widget.icon!, const SizedBox(width: 8)],
          Expanded(
            child: widget.multipleSelect && mySelectedItems.isNotEmpty
                ? SizedBox(
                    height: 30,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        if (mySelectedItems.isEmpty) const Text(""),
                        for (String item in mySelectedItems)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (widget.multiSelectChipColor ??
                                          widget.configuration?.primaryColor ??
                                          const Color(0xFF2196F3))
                                      .withOpacityNew(0.2),
                              borderRadius: BorderRadius.circular(
                                widget.itemBorderRadius ?? 6,
                              ),
                            ),
                            child: Text(
                              item,
                              style: TextStyle(fontSize: widget.fontSize ?? 14),
                            ),
                          ),
                      ],
                    ),
                  )
                : Text(
                    text.isEmpty ? widget.hintText ?? "" : text,
                    textAlign: widget.textAlign,
                    style: TextStyle(
                      color:
                          myColor ??
                          (text.isEmpty
                              ? (widget.configuration?.secondaryTextColor ??
                                        const Color(0xFF6B6B6B))
                                    .withOpacityNew(0.6)
                              : widget.configuration?.rowForegroundColor),
                      fontSize: widget.fontSize ?? 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          const SizedBox(width: 4),
          if (widget.showClearButton)
            if ((myText?.isNotEmpty ?? false) ||
                (widget.multipleSelect && mySelectedItems.isNotEmpty))
              IconButton(
                onPressed: () {
                  if (widget.multipleSelect) {
                    selectedItems.clear();
                    mySelectedItems.clear();
                    myText = "";
                    myColor = null;
                    myValue = null;
                    widget.state.didChange("");
                    widget.onTouchOutSide?.call([]);
                  } else {
                    mySelectedItems.clear();
                    myText = "";
                    myColor = null;
                    myValue = null;
                    widget.state.didChange("");
                    widget.onChange?.call("");
                  }
                  if (mounted) setState(() {});
                },
                icon: Icon(
                  Icons.close,
                  size: 20,
                  color:
                      widget.configuration?.errorColor ??
                      const Color(0xFFF44336),
                ),
              ),
          Icon(
            isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color:
                widget.configuration?.secondaryTextColor ??
                const Color(0xFF6B6B6B),
          ),
        ],
      ),
    );
  }
}
