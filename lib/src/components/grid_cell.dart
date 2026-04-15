import 'package:om_data_grid/src/utils/cell_formatters.dart';
import 'package:om_data_grid/src/enums/grid_row_type_enum.dart';
import 'package:om_data_grid/src/models/grid_column_model.dart';
import 'package:om_data_grid/src/components/grid_substring_highlight.dart';
import 'package:om_data_grid/src/components/grid_combo_box/grid_combo_box.dart';
import 'package:om_data_grid/src/models/datagrid_configuration.dart';
import 'package:om_data_grid/src/utils/general_helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:om_data_grid/src/utils/file_picker_wrapper/file_picker_wrapper.dart';
import 'dart:ui' as ui;
import 'package:om_data_grid/src/components/default_button.dart';

class GridCell extends StatefulWidget {
  final OmGridColumnModel column;
  final dynamic value;
  final List<String> searchTerms;
  final TextStyle style;
  final Map<String, dynamic> row;
  final void Function(String key, dynamic value)? onValueChange;
  final bool isEditing;
  final bool isActiveEditCell;
  final void Function(bool forward)? onNavigateCell;
  final OmDataGridConfiguration configuration;

  const GridCell({
    super.key,
    required this.column,
    required this.value,
    this.searchTerms = const [],
    this.style = const TextStyle(),
    required this.row,
    this.onValueChange,
    this.isEditing = false,
    this.isActiveEditCell = false,
    this.onNavigateCell,
    required this.configuration,
  });

  @override
  State<GridCell> createState() => _GridCellState();
}

class _GridCellState extends State<GridCell> {
  static final ImagePicker _picker = ImagePicker();
  final MenuController _menuController = MenuController();
  bool _menuOpenedAbove = false;
  Offset _menuOffset = Offset.zero;

  // For inline text/number editing
  TextEditingController? _textEditingController;
  FocusNode? _editFocusNode;

  bool get _isInlineTextType =>
      widget.column.type == OmGridRowTypeEnum.text ||
      widget.column.type == OmGridRowTypeEnum.integer ||
      widget.column.type == OmGridRowTypeEnum.double ||
      widget.column.type == OmGridRowTypeEnum.date ||
      widget.column.type == OmGridRowTypeEnum.dateTime ||
      widget.column.type == OmGridRowTypeEnum.time;

  bool get _isDateType =>
      widget.column.type == OmGridRowTypeEnum.date ||
      widget.column.type == OmGridRowTypeEnum.dateTime ||
      widget.column.type == OmGridRowTypeEnum.time;

  String _getDefaultDateMask() {
    switch (widget.column.type) {
      case OmGridRowTypeEnum.time:
        return 'HH:mm';
      case OmGridRowTypeEnum.dateTime:
        return 'dd/MM/yyyy HH:mm';
      default:
        return 'dd/MM/yyyy';
    }
  }

  String _getEditMask() =>
      widget.column.customDateFormat ?? _getDefaultDateMask();

  /// Formats [value] into the masked display string for the date editor.
  /// Returns the empty mask (e.g. "__/__/____") when the value cannot be parsed.
  String _formatValueForMask(dynamic value, String mask) {
    final emptyMask = _MaskedDateInputFormatter.buildEmptyMask(mask);
    if (value == null) return emptyMask;
    final bool isTimeType = widget.column.type == OmGridRowTypeEnum.time;
    // Pass [mask] as an additional pattern so previously-saved masked strings
    // (e.g. "15/04/2024") are recognised even when ISO parsing fails.
    final DateTime? date = OmGridDateTimeUtils.tryParse(
      value,
      isTime: isTimeType,
      pattern: mask,
    );
    if (date == null) return emptyMask;
    try {
      return OmGridCellFormatters.getDateFormat(mask).format(date);
    } catch (_) {
      return emptyMask;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.isActiveEditCell && _isInlineTextType) {
      _initEditingResources();
    }
  }

  void _initEditingResources() {
    _editFocusNode ??= FocusNode();
    if (_textEditingController == null) {
      final String initialText = _isDateType
          ? _formatValueForMask(widget.value, _getEditMask())
          : (widget.value?.toString() ?? '');
      if (_isDateType) {
        final fg = widget.configuration.rowForegroundColor;
        _textEditingController = _MaskedDateTextController(
          mask: _getEditMask(),
          placeholderColor: fg.withOpacity(0.20),
          separatorColor: fg.withOpacity(0.40),
          initialText: initialText,
        );
      } else {
        _textEditingController = TextEditingController(text: initialText);
      }
    }
  }

  @override
  void didUpdateWidget(GridCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isInlineTextType) {
      if (widget.isActiveEditCell) {
        _initEditingResources();
        // Sync controller value if external value changed while not editing
        if (!oldWidget.isActiveEditCell) {
          final newText = _isDateType
              ? _formatValueForMask(widget.value, _getEditMask())
              : (widget.value?.toString() ?? '');
          _textEditingController!.text = newText;
        }
        // Request focus when this cell becomes the active edit cell
        if (!oldWidget.isActiveEditCell) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _editFocusNode!.requestFocus();
              _textEditingController!.selection = TextSelection(
                baseOffset: 0,
                extentOffset: _textEditingController!.text.length,
              );
            }
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _textEditingController?.dispose();
    _editFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.column.key == '__reorder_column__') {
      return Icon(Icons.drag_indicator,
          color: widget.configuration.secondaryTextColor);
    }

    final Widget defaultWidget = _buildDefaultWidget(context);

    final builder = widget.column.widgetBuilder;
    if (builder != null) {
      return builder(widget.value, widget.row, defaultWidget);
    }

    return defaultWidget;
  }

  /// Builds the default widget for the current column type, used as the
  /// [defaultWidget] argument passed to [OmGridColumn.widgetBuilder].
  Widget _buildDefaultWidget(BuildContext context) {
    switch (widget.column.type) {
      case OmGridRowTypeEnum.integer:
        return widget.isActiveEditCell ? _buildTextEditor() : _buildInt();

      case OmGridRowTypeEnum.double:
        return widget.isActiveEditCell ? _buildTextEditor() : _buildDouble();

      case OmGridRowTypeEnum.date:
      case OmGridRowTypeEnum.dateTime:
      case OmGridRowTypeEnum.time:
        return widget.isActiveEditCell ? _buildDateEditor() : _buildDate();

      case OmGridRowTypeEnum.comboBox:
        return widget.isActiveEditCell
            ? _buildComboBoxEditor()
            : _buildComboBoxView();

      case OmGridRowTypeEnum.iosSwitch:
        return _buildSwitch();

      case OmGridRowTypeEnum.image:
        return _buildImage(isFile: false);

      case OmGridRowTypeEnum.profileImage:
        return _buildProfileImage();

      case OmGridRowTypeEnum.file:
        return _buildImage(isFile: true);

      case OmGridRowTypeEnum.multiImage:
      case OmGridRowTypeEnum.multiFile:
        return _buildMultiImageOrFile();

      case OmGridRowTypeEnum.delete:
        return _buildDelete(context);

      case OmGridRowTypeEnum.contextMenu:
        return _buildContextMenu(context);

      case OmGridRowTypeEnum.state:
        return widget.isActiveEditCell ? _buildStateEditor() : _buildState();

      case OmGridRowTypeEnum.widget:
      case OmGridRowTypeEnum.button:
      case OmGridRowTypeEnum.code:
      case OmGridRowTypeEnum.reordable:
        return _buildText(widget.value?.toString() ?? '');

      case OmGridRowTypeEnum.text:
        return widget.isActiveEditCell
            ? _buildTextEditor()
            : _buildText(widget.value?.toString() ?? '');
    }
  }

  Widget _buildProfileImage() {
    final bool hasValue =
        widget.value != null && widget.value.toString().isNotEmpty;
    final bool canEdit =
        (widget.column.readonlyInView != true) || widget.isEditing;

    if (!hasValue) {
      if (canEdit && widget.isEditing) {
        return IconButton(
          onPressed: _pickImage,
          icon: const Icon(Icons.add_a_photo, size: 20),
          tooltip: 'Add Profile Photo',
        );
      }
      return CircleAvatar(
        radius: 16,
        backgroundColor:
            widget.configuration.secondaryTextColor.withOpacity(0.1),
        child: Icon(Icons.person,
            color: widget.configuration.secondaryTextColor, size: 20),
      );
    }

    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        GestureDetector(
          onTap: () {
            GridFileViewerUtils.showViewer(
              context: context,
              url: widget.value.toString(),
              title: widget.column.title,
              configuration: widget.configuration,
              isImage: true,
            );
          },
          child: CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(widget.value.toString()),
            onBackgroundImageError: (exception, stackTrace) {},
          ),
        ),
        if (canEdit && widget.isEditing)
          Positioned(
            right: -10,
            bottom: -10,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const CircleAvatar(
                radius: 8,
                backgroundColor: Colors.blue,
                child: Icon(Icons.edit, color: Colors.white, size: 10),
              ),
              onPressed: _pickImage,
            ),
          ),
      ],
    );
  }

  Widget _buildTextEditor() {
    _initEditingResources();
    return Focus(
      // Intercept Tab/Shift+Tab before Flutter's focus traversal handles it
      onKeyEvent: (node, event) {
        if ((event is KeyDownEvent || event is KeyRepeatEvent) &&
            event.logicalKey == LogicalKeyboardKey.tab) {
          final forward = !HardwareKeyboard.instance.isShiftPressed;
          widget.onNavigateCell?.call(forward);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: TextField(
        focusNode: _editFocusNode,
        controller: _textEditingController,
        style: widget.style,
        decoration: const InputDecoration.collapsed(hintText: ''),
        keyboardType: widget.column.type == OmGridRowTypeEnum.integer
            ? TextInputType.number
            : widget.column.type == OmGridRowTypeEnum.double
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
        textAlign: widget.column.textAlign,
        onChanged: (val) => widget.onValueChange?.call(widget.column.key, val),
      ),
    );
  }

  Widget _buildText(String text) {
    if (widget.searchTerms.isEmpty) {
      return Text(
        text,
        textAlign: widget.column.textAlign,
        style: widget.style,
        overflow: TextOverflow.ellipsis,
      );
    }
    return GridSubstringHighlight(
      text: text,
      terms: widget.searchTerms,
      textAlign: widget.column.textAlign,
      textStyle: widget.style,
      textStyleHighlight: widget.style.copyWith(
        backgroundColor: Colors.yellow,
        color: Colors.black,
      ),
    );
  }

  Widget _buildDouble() {
    if (widget.value == null) return _buildText('');
    final bool isNum = widget.value is num;
    final bool isNumericString = !isNum &&
        (widget.value is String && double.tryParse(widget.value) != null);

    if (!isNum && !isNumericString) {
      return _buildText(widget.value.toString());
    }

    final double val =
        isNum ? widget.value.toDouble() : double.parse(widget.value);

    return _buildText(
      OmGridCellFormatters.formatNumber(
        value: val,
        digits: widget.column.decimalDigits,
        decimalSeparator: widget.column.decimalSeparator,
        thousandsSeparator: widget.column.thousandsSeparator,
      ),
    );
  }

  Widget _buildDateEditor() {
    _initEditingResources();
    final mask = _getEditMask();
    return Focus(
      onKeyEvent: (node, event) {
        if ((event is KeyDownEvent || event is KeyRepeatEvent) &&
            event.logicalKey == LogicalKeyboardKey.tab) {
          final forward = !HardwareKeyboard.instance.isShiftPressed;
          widget.onNavigateCell?.call(forward);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: TextField(
        focusNode: _editFocusNode,
        controller: _textEditingController,
        style: widget.style,
        decoration: const InputDecoration.collapsed(hintText: ''),
        keyboardType: TextInputType.number,
        inputFormatters: [_MaskedDateInputFormatter(mask)],
        textAlign: widget.column.textAlign,
        onChanged: (val) => widget.onValueChange?.call(widget.column.key, val),
      ),
    );
  }

  Widget _buildDate() {
    if (widget.value == null) return _buildText('');

    final bool isTimeType = widget.column.type == OmGridRowTypeEnum.time;
    // Also try the edit-mask pattern so that values typed via the masked editor
    // (e.g. "15/04/2024") are parsed and displayed correctly.
    final DateTime? date = OmGridDateTimeUtils.tryParse(
      widget.value,
      isTime: isTimeType,
      pattern: _getEditMask(),
    );

    if (date == null) return _buildText(widget.value.toString());

    if (widget.column.customDateFormat != null) {
      try {
        return _buildText(
          OmGridCellFormatters.getDateFormat(
            widget.column.customDateFormat!,
          ).format(date),
        );
      } catch (e) {
        return _buildText(date.toString());
      }
    }
    return _buildText(OmGridCellConstants.defaultDateFormatter.format(date));
  }

  Widget _buildComboBoxView() {
    if (widget.value == null) return _buildText('');

    final options = widget.column.comboBoxSettings?.items;
    String text = widget.value.toString();

    if (options != null) {
      if (widget.column.multiSelect == true && widget.value is List) {
        final List<String> selectedLabels = [];
        for (var val in widget.value) {
          final option = options.firstWhere(
            (o) => o.value == val.toString(),
            orElse: () =>
                OmGridComboBoxItem(value: val.toString(), text: val.toString()),
          );
          selectedLabels.add(option.text);
        }
        text = selectedLabels.join(', ');
      } else {
        final option = options.firstWhere(
          (o) => o.value == widget.value.toString(),
          orElse: () => OmGridComboBoxItem(
            value: widget.value.toString(),
            text: widget.value.toString(),
          ),
        );
        text = option.text;
      }
    }
    return _buildText(text);
  }

  Widget _buildComboBoxEditor() {
    // Resolve initialValue: use the stored value if it already matches a
    // combobox item's .value; otherwise look up by .text (handles the common
    // case where row data stores the display label instead of the raw value).
    final items = widget.column.comboBoxSettings?.items ?? [];
    final rawValue = widget.value?.toString() ?? '';
    String resolvedInitialValue = rawValue;
    if (rawValue.isNotEmpty) {
      final matchesByValue = items.any(
        (item) => item.value.toString() == rawValue,
      );
      if (!matchesByValue) {
        final byText = items.where((item) => item.text == rawValue);
        if (byText.isNotEmpty) {
          resolvedInitialValue = byText.first.value.toString();
        }
      }
    }

    // LayoutBuilder reads the actual available height after border + padding
    // are applied by the parent cell container, so we never overflow regardless
    // of whether the active-cell border is present (3px) or not.
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : widget.configuration.rowHeight - 8;
        return ClipRect(
          child: SizedBox(
            height: h,
            child: GridComboBox(
              initialValue: resolvedInitialValue,
              items: widget.column.comboBoxSettings?.items ?? [],
              onChange: (newVal) {
                widget.onValueChange?.call(widget.column.key, newVal);
              },
              configuration: widget.configuration,
              height: h,
              contentPadding: EdgeInsets.zero,
              borderColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              borderRadius: 0,
              showClearButton: false,
              fontSize: 14,
              autoOpen: true,
              onTabPressed: widget.onNavigateCell,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwitch() {
    bool isTrue = false;
    if (widget.value is bool) {
      isTrue = widget.value;
    } else if (widget.value is int) {
      isTrue = widget.value == 1;
    } else if (widget.value is String) {
      isTrue = widget.value.toLowerCase() == 'true';
    }

    final bool readOnly =
        widget.column.readonlyInView == true && !widget.isEditing;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: IgnorePointer(
        ignoring: readOnly,
        child: Transform.scale(
          scale: 0.75, // Smaller iOS Switch
          child: CupertinoSwitch(
            value: isTrue,
            activeColor:
                widget.configuration.primaryColor, // Take primary color
            onChanged: (newValue) {
              if (widget.onValueChange != null) {
                widget.onValueChange!(widget.column.key, newValue);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildImage({bool isFile = false}) {
    final bool hasValue =
        widget.value != null && widget.value.toString().isNotEmpty;
    final bool canEdit =
        (widget.column.readonlyInView != true) || widget.isEditing;
    final double radius = widget.column.imageBorderRadius ?? (isFile ? 4 : 8);

    if (!hasValue) {
      if (canEdit && widget.isEditing) {
        return Center(
          child: OmDefaultButton(
            configuration: widget.configuration,
            height: 28,
            width: 110,
            text: isFile ? 'Upload file' : 'Upload image',
            leadingIcon: Icon(
              isFile ? Icons.upload_file : Icons.add_photo_alternate,
              size: 13,
              color: widget.configuration.primaryForegroundColor,
            ),
            fontsize: 11,
            fontWeight: FontWeight.w500,
            press: () async => isFile ? _pickFile() : _pickImage(),
          ),
        );
      }
      return Center(
        child: Icon(
          isFile ? Icons.insert_drive_file : Icons.image,
          color: widget.configuration.secondaryTextColor.withOpacity(0.4),
          size: 22,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () {
              GridFileViewerUtils.showViewer(
                context: context,
                url: widget.value.toString(),
                title: widget.column.title,
                configuration: widget.configuration,
                isImage: !isFile,
              );
            },
            child: isFile
                ? Container(
                    color: widget.configuration.secondaryTextColor
                        .withOpacity(0.06),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.insert_drive_file,
                            size: 26,
                            color: widget.configuration.secondaryTextColor),
                        const SizedBox(height: 2),
                        Text(
                          _fileExtension(widget.value.toString()),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: widget.configuration.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : Image.network(
                    widget.value.toString(),
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, stack) => Container(
                      color: widget.configuration.secondaryTextColor
                          .withOpacity(0.06),
                      child: Icon(Icons.broken_image,
                          color: widget.configuration.secondaryTextColor
                              .withOpacity(0.4)),
                    ),
                  ),
          ),
          if (canEdit && widget.isEditing)
            PositionedDirectional(
              top: -5,
              end: -35,
              start: 0,
              child: GestureDetector(
                onTap: () =>
                    widget.onValueChange?.call(widget.column.key, null),
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 12),
                ),
              ),
            ),
          if (canEdit && widget.isEditing)
            PositionedDirectional(
              bottom: -5,
              start: -35,
              end: 0,
              child: GestureDetector(
                onTap: () => isFile ? _pickFile() : _pickImage(),
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: widget.configuration.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(isFile ? Icons.upload_file : Icons.photo_camera,
                      color: widget.configuration.primaryForegroundColor,
                      size: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _fileExtension(String path) {
    final parts = path.split('.');
    return parts.length > 1 ? '.${parts.last.toUpperCase()}' : 'FILE';
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      widget.onValueChange?.call(widget.column.key, image.path);
    }
  }

  Future<void> _pickFile() async {
    final String? path = await FilePickerWrapper.pickFile();
    if (path != null) {
      widget.onValueChange?.call(widget.column.key, path);
    }
  }

  Widget _buildMultiImageOrFile() {
    if (widget.value is! List || (widget.value as List).isEmpty) {
      return const SizedBox();
    }
    final list = widget.value as List;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: list.take(3).map<Widget>((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: CircleAvatar(
            radius: 12,
            backgroundImage: NetworkImage(item.toString()),
            onBackgroundImageError: (_, __) {},
            child: const Icon(Icons.error, size: 10),
          ),
        );
      }).toList()
        ..add(
          list.length > 3
              ? Text('+${list.length - 3}', style: widget.style)
              : const SizedBox(),
        ),
    );
  }

  Widget _buildDelete(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return MenuAnchor(
      controller: _menuController,
      alignmentOffset: _menuOffset,
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(Colors.transparent),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        elevation: WidgetStateProperty.all(0),
        padding: WidgetStateProperty.all(EdgeInsets.zero),
      ),
      builder: (context, controller, child) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              final RenderBox? box = context.findRenderObject() as RenderBox?;
              if (box != null) {
                final position = box.localToGlobal(Offset.zero);
                final screenHeight = MediaQuery.of(context).size.height;

                setState(() {
                  _menuOpenedAbove = (screenHeight - position.dy <
                      widget.configuration.rowHeight * 4);
                  if (isRTL) {
                    _menuOffset = const Offset(-230, 0);
                  } else {
                    _menuOffset = const Offset(-225, 0);
                  }
                });
              }
              controller.open();
            }
          },
          icon: Icon(Icons.delete, color: widget.configuration.errorColor),
        );
      },
      menuChildren: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              alignment: _menuOpenedAbove
                  ? AlignmentDirectional.bottomEnd
                  : AlignmentDirectional.topEnd,
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Material(
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.4),
            shape: _ArrowShape(
              arrowOnTop: !_menuOpenedAbove,
              configuration: widget.configuration,
            ),
            color: widget.configuration.menuBackgroundColor ?? Colors.white,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 24, 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 20,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.configuration.labels.deleteRowTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: widget.configuration.rowForegroundColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 28.0),
                      child: Text(
                        widget.configuration.labels.deleteRowConfirmation,
                        style: TextStyle(
                          color: widget.configuration.secondaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Spacer(),
                        SizedBox(
                          height: 30,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              side: BorderSide(
                                color: widget.configuration.inputBorderColor,
                              ),
                              backgroundColor:
                                  widget.configuration.gridBackgroundColor,
                              foregroundColor:
                                  widget.configuration.rowForegroundColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: () {
                              _menuController.close();
                            },
                            child: Text(widget.configuration.labels.no),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 30,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              backgroundColor:
                                  widget.configuration.primaryColor,
                              foregroundColor:
                                  widget.configuration.primaryForegroundColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: () async {
                              _menuController.close();
                              final onDelete = widget.column.onDelete;
                              if (onDelete != null) {
                                await onDelete(widget.row);
                              }
                            },
                            child: Text(widget.configuration.labels.yes),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContextMenu(BuildContext context) {
    return PopupMenuButton<dynamic>(
      icon: const Icon(Icons.more_horiz),
      onSelected: (val) {
        final option = widget.column.contextMenuOptions?.firstWhere(
          (o) => o.value == val,
        );
        option?.onTap?.call(widget.row);
      },
      itemBuilder: (ctx) {
        return (widget.column.contextMenuOptions ?? []).map((opt) {
          return PopupMenuItem(
            value: opt.value,
            child: Row(
              children: [
                if (opt.icon != null) Icon(opt.icon, size: 18),
                if (opt.icon != null) const SizedBox(width: 8),
                Text(opt.label),
              ],
            ),
          );
        }).toList();
      },
    );
  }

  Widget _buildStateEditor() {
    final items = (widget.column.stateConfig?.entries ?? [])
        .map(
          (e) => OmGridComboBoxItem(
            value: e.key.toString(),
            text: e.value.label,
          ),
        )
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : widget.configuration.rowHeight - 8;
        return ClipRect(
          child: SizedBox(
            height: h,
            child: GridComboBox(
              initialValue: widget.value?.toString() ?? '',
              items: items,
              onChange: (newVal) {
                widget.onValueChange?.call(widget.column.key, newVal);
              },
              configuration: widget.configuration,
              height: h,
              contentPadding: EdgeInsets.zero,
              borderColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              borderRadius: 0,
              showClearButton: false,
              fontSize: 14,
              autoOpen: true,
              onTabPressed: widget.onNavigateCell,
            ),
          ),
        );
      },
    );
  }

  Widget _buildState() {
    final config = widget.column.stateConfig?[widget.value];
    if (config == null) return _buildText(widget.value?.toString() ?? '');

    final Color baseColor = config.color;
    final bool isPrimary = config.style == OmStateStyle.primary;
    final Color foregroundColor = isPrimary ? Colors.white : baseColor;

    final label = Text(
      config.label,
      style: widget.style.copyWith(color: foregroundColor),
    );

    final icon = config.icon != null
        ? Icon(config.icon, size: 16, color: foregroundColor)
        : null;

    switch (config.style) {
      case OmStateStyle.tinted:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: baseColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) icon,
              if (icon != null) const SizedBox(width: 4),
              label,
            ],
          ),
        );
      case OmStateStyle.primary:
        return Chip(
          label: label,
          backgroundColor: baseColor,
          avatar: icon,
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      case OmStateStyle.outlined:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: baseColor),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) icon,
              if (icon != null) const SizedBox(width: 4),
              label,
            ],
          ),
        );
      case OmStateStyle.text:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) icon,
            if (icon != null) const SizedBox(width: 4),
            label,
          ],
        );
    }
  }

  Widget _buildInt() {
    if (widget.value == null) return _buildText('');
    final bool isNum = widget.value is num;
    final bool isNumericString = !isNum &&
        (widget.value is String && int.tryParse(widget.value) != null);

    if (!isNum && !isNumericString) {
      return _buildText(widget.value.toString());
    }

    final double val =
        isNum ? widget.value.toDouble() : double.parse(widget.value);

    return _buildText(
      OmGridCellFormatters.formatNumber(
        value: val,
        digits: widget.column.decimalDigits ?? 0,
        decimalSeparator: widget.column.decimalSeparator,
        thousandsSeparator: widget.column.thousandsSeparator,
      ),
    );
  }
}

/// A [TextEditingController] that renders the three character categories of a
/// masked date/time string with distinct colours:
///   • filled digits   → normal text colour (inherited from the [TextField] style)
///   • placeholder '_' → very faint (the digit position is empty)
///   • separator chars → muted (e.g. '/', '-', ':', ' ')
class _MaskedDateTextController extends TextEditingController {
  final String mask;
  final Color placeholderColor;
  final Color separatorColor;

  static const Set<String> _maskDigitChars = {
    'd',
    'M',
    'y',
    'H',
    'h',
    'm',
    's',
    'S',
  };

  _MaskedDateTextController({
    required this.mask,
    required this.placeholderColor,
    required this.separatorColor,
    String? initialText,
  }) : super(text: initialText);

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final txt = text;
    if (txt.isEmpty) return TextSpan(style: style);

    final spans = <InlineSpan>[];
    for (int i = 0; i < txt.length && i < mask.length; i++) {
      final ch = txt[i];
      final isDigitPos = _maskDigitChars.contains(mask[i]);

      final Color color;
      if (isDigitPos) {
        color = ch == '_' ? placeholderColor : (style?.color ?? Colors.black);
      } else {
        color = separatorColor;
      }

      spans.add(
        TextSpan(
          text: ch,
          style: (style ?? const TextStyle()).copyWith(color: color),
        ),
      );
    }

    return TextSpan(style: style, children: spans);
  }
}

/// A [TextInputFormatter] that enforces a date/time mask such as "dd/MM/yyyy"
/// or "HH:mm". Separator characters (anything that is not a mask-letter) are
/// kept fixed; only the digit positions (d, M, y, H, h, m, s, S) are editable.
///
/// The user types plain digits; the formatter places them into the next
/// available mask position and auto-advances the cursor past separators.
/// Backspace clears the digit immediately before the cursor.
class _MaskedDateInputFormatter extends TextInputFormatter {
  final String mask;

  static const Set<String> _maskDigitChars = {
    'd',
    'M',
    'y',
    'H',
    'h',
    'm',
    's',
    'S',
  };

  _MaskedDateInputFormatter(this.mask);

  bool _isDigitPos(int i) =>
      i >= 0 && i < mask.length && _maskDigitChars.contains(mask[i]);

  /// Builds the "empty" version of the mask, e.g. "__/__/____" for "dd/MM/yyyy".
  static String buildEmptyMask(String mask) =>
      mask.split('').map((c) => _maskDigitChars.contains(c) ? '_' : c).join();

  String get _emptyMask => buildEmptyMask(mask);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Ensure the base is always a full-length masked string.
    final base =
        oldValue.text.length == mask.length ? oldValue.text : _emptyMask;
    final oldCursor = oldValue.selection.baseOffset.clamp(0, mask.length);
    final lengthDiff = newValue.text.length - oldValue.text.length;

    if (lengthDiff > 0) {
      // ── Insertion ──────────────────────────────────────────────────────────
      if (lengthDiff == 1) {
        // Single character typed.
        final insertedAt = newValue.selection.baseOffset - 1;
        if (insertedAt < 0 || insertedAt >= newValue.text.length)
          return oldValue;
        final ch = newValue.text[insertedAt];
        if (!RegExp(r'\d').hasMatch(ch)) return oldValue; // reject non-digits

        int pos = oldCursor;
        while (pos < mask.length && !_isDigitPos(pos)) {
          pos++;
        }
        if (pos >= mask.length) return oldValue; // mask fully filled

        final chars = base.split('');
        chars[pos] = ch;
        final result = chars.join();

        int nextCursor = pos + 1;
        while (nextCursor < mask.length && !_isDigitPos(nextCursor)) {
          nextCursor++;
        }

        return TextEditingValue(
          text: result,
          selection: TextSelection.collapsed(
            offset: nextCursor.clamp(0, mask.length),
          ),
        );
      } else {
        // Paste: extract every digit and refill from left.
        return _refillFromDigits(newValue.text);
      }
    } else if (lengthDiff < 0) {
      // ── Deletion ───────────────────────────────────────────────────────────
      if (lengthDiff == -1) {
        // Single backspace.
        int clearPos = oldCursor - 1;
        while (clearPos >= 0 && !_isDigitPos(clearPos)) {
          clearPos--;
        }

        if (clearPos < 0) {
          return TextEditingValue(
            text: base,
            selection: const TextSelection.collapsed(offset: 0),
          );
        }

        final chars = base.split('');
        chars[clearPos] = '_';

        return TextEditingValue(
          text: chars.join(),
          selection: TextSelection.collapsed(offset: clearPos),
        );
      } else {
        // Multi-char deletion (e.g. select-all + delete): keep empty mask.
        return TextEditingValue(
          text: _emptyMask,
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    }

    // No length change — cursor move or same content; keep the base text.
    final newCursor = newValue.selection.baseOffset.clamp(0, mask.length);
    return TextEditingValue(
      text: base,
      selection: TextSelection.collapsed(offset: newCursor),
    );
  }

  /// Extracts all digits from [raw] and fills them into the mask left-to-right.
  TextEditingValue _refillFromDigits(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    int digitIdx = 0;
    for (int i = 0; i < mask.length; i++) {
      if (_isDigitPos(i)) {
        buf.write(digitIdx < digits.length ? digits[digitIdx++] : '_');
      } else {
        buf.write(mask[i]);
      }
    }
    // Place cursor just after the last filled digit position.
    int cursor = 0;
    final result = buf.toString();
    for (int i = 0; i < mask.length; i++) {
      if (_isDigitPos(i) && result[i] != '_') cursor = i + 1;
    }
    while (cursor < mask.length && !_isDigitPos(cursor)) {
      cursor++;
    }
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: cursor.clamp(0, mask.length)),
    );
  }
}

class _ArrowShape extends ShapeBorder {
  final bool arrowOnTop;
  final OmDataGridConfiguration configuration;

  const _ArrowShape({this.arrowOnTop = true, required this.configuration});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  ui.Path getInnerPath(ui.Rect rect, {ui.TextDirection? textDirection}) =>
      ui.Path();

  @override
  ui.Path getOuterPath(ui.Rect rect, {ui.TextDirection? textDirection}) {
    const double arrowWidth = 14.0;
    const double arrowHeight = 8.0;
    // Arrow should point to exactly 24px from the edge of the popconfirm
    // (which is the center of the 48px IconButton)
    const double arrowOffset = 24.0;
    const double radius = 10.0;

    final bool isRtl = textDirection == ui.TextDirection.rtl;

    if (arrowOnTop) {
      final r = ui.Rect.fromLTRB(
        rect.left,
        rect.top + arrowHeight,
        rect.right,
        rect.bottom,
      );

      final path = ui.Path()..moveTo(r.left + radius, r.top);

      if (isRtl) {
        // Arrow points to button center (24px from anchor right)
        // In LTR, anchor starts at top-left.
        // Let's make it simple: arrow is ALWAYS 24px from the edge closest to the button.
        path
          ..lineTo(r.left + arrowOffset - (arrowWidth / 2), r.top)
          ..lineTo(r.left + arrowOffset, rect.top)
          ..lineTo(r.left + arrowOffset + (arrowWidth / 2), r.top);
      } else {
        path
          ..lineTo(r.right - arrowOffset - (arrowWidth / 2), r.top)
          ..lineTo(r.right - arrowOffset, rect.top)
          ..lineTo(r.right - arrowOffset + (arrowWidth / 2), r.top);
      }

      return path
        ..lineTo(r.right - radius, r.top)
        ..arcToPoint(
          Offset(r.right, r.top + radius),
          radius: const Radius.circular(radius),
        )
        ..lineTo(r.right, r.bottom - radius)
        ..arcToPoint(
          Offset(r.right - radius, r.bottom),
          radius: const Radius.circular(radius),
        )
        ..lineTo(r.left + radius, r.bottom)
        ..arcToPoint(
          Offset(r.left, r.bottom - radius),
          radius: const Radius.circular(radius),
        )
        ..lineTo(r.left, r.top + radius)
        ..arcToPoint(
          Offset(r.left + radius, r.top),
          radius: const Radius.circular(radius),
        )
        ..close();
    } else {
      final r = ui.Rect.fromLTRB(
        rect.left,
        rect.top,
        rect.right,
        rect.bottom - arrowHeight,
      );

      final path = ui.Path()..moveTo(r.left + radius, r.top);
      path
        ..lineTo(r.right - radius, r.top)
        ..arcToPoint(
          Offset(r.right, r.top + radius),
          radius: const Radius.circular(radius),
        )
        ..lineTo(r.right, r.bottom - radius)
        ..arcToPoint(
          Offset(r.right - radius, r.bottom),
          radius: const Radius.circular(radius),
        );

      if (isRtl) {
        path
          ..lineTo(r.left + arrowOffset + (arrowWidth / 2), r.bottom)
          ..lineTo(r.left + arrowOffset, rect.bottom)
          ..lineTo(r.left + arrowOffset - (arrowWidth / 2), r.bottom);
      } else {
        path
          ..lineTo(r.right - arrowOffset + (arrowWidth / 2), r.bottom)
          ..lineTo(r.right - arrowOffset, rect.bottom)
          ..lineTo(r.right - arrowOffset - (arrowWidth / 2), r.bottom);
      }

      return path
        ..lineTo(r.left + radius, r.bottom)
        ..arcToPoint(
          Offset(r.left, r.bottom - radius),
          radius: const Radius.circular(radius),
        )
        ..lineTo(r.left, r.top + radius)
        ..arcToPoint(
          Offset(r.left + radius, r.top),
          radius: const Radius.circular(radius),
        )
        ..close();
    }
  }

  @override
  void paint(
    ui.Canvas canvas,
    ui.Rect rect, {
    ui.TextDirection? textDirection,
  }) {
    final paint = Paint()
      ..color = configuration.rowBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(getOuterPath(rect, textDirection: textDirection), paint);
  }

  @override
  ShapeBorder scale(double t) =>
      _ArrowShape(arrowOnTop: arrowOnTop, configuration: configuration);
}
