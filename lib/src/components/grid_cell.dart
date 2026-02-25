import 'package:om_data_grid/src/utils/cell_formatters.dart';
import 'package:om_data_grid/src/enums/grid_row_type_enum.dart';
import 'package:om_data_grid/src/models/grid_column_model.dart';
import 'package:om_data_grid/src/components/grid_substring_highlight.dart';
import 'package:om_data_grid/src/components/grid_combo_box/grid_combo_box.dart';
import 'package:om_data_grid/src/models/datagrid_configuration.dart';
import 'package:om_data_grid/src/utils/general_helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:om_data_grid/src/utils/file_picker_wrapper/file_picker_wrapper.dart';
import 'dart:ui' as ui;

class GridCell extends StatefulWidget {
  final OmGridColumnModel column;
  final dynamic value;
  final List<String> searchTerms;
  final TextStyle style;
  final Map<String, dynamic> row;
  final void Function(String key, dynamic value)? onValueChange;
  final bool isEditing;
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
    required this.configuration,
  });

  @override
  State<GridCell> createState() => _GridCellState();
}

class _GridCellState extends State<GridCell> {
  static final ImagePicker _picker = ImagePicker();
  final MenuController _menuController = MenuController();
  bool _menuOpenedAbove = false;

  @override
  Widget build(BuildContext context) {
    if (widget.column.key == '__reorder_column__') {
      return Icon(Icons.drag_indicator,
          color: widget.configuration.secondaryTextColor);
    }

    switch (widget.column.type) {
      case OmGridRowTypeEnum.integer:
        return _buildInt();

      case OmGridRowTypeEnum.double:
        return _buildDouble();

      case OmGridRowTypeEnum.date:
      case OmGridRowTypeEnum.dateTime:
      case OmGridRowTypeEnum.time:
        return _buildDate();

      case OmGridRowTypeEnum.comboBox:
        return widget.isEditing ? _buildComboBoxEditor() : _buildComboBoxView();

      case OmGridRowTypeEnum.iosSwitch:
        return _buildSwitch();

      case OmGridRowTypeEnum.image:
        return _buildImage(isFile: false);

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
        return _buildState();

      case OmGridRowTypeEnum.text:
      default:
        return _buildText(widget.value?.toString() ?? '');
    }
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

  Widget _buildDate() {
    if (widget.value == null) return _buildText('');

    final bool isTimeType = widget.column.type == OmGridRowTypeEnum.time;
    final DateTime? date = OmGridDateTimeUtils.tryParse(
      widget.value,
      isTime: isTimeType,
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
    return GridComboBox(
      initialValue: widget.value?.toString() ?? '',
      items: widget.column.comboBoxSettings?.items ?? [],
      onChange: (newVal) {
        widget.onValueChange?.call(widget.column.key, newVal);
      },
      configuration: widget.configuration,
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

    if (!hasValue) {
      if (canEdit && widget.isEditing) {
        return TextButton.icon(
          onPressed: () => isFile ? _pickFile() : _pickImage(),
          icon: const Icon(Icons.add_a_photo, size: 16),
          label: const Text('Add', style: TextStyle(fontSize: 12)),
        );
      }
      return isFile
          ? Icon(Icons.insert_drive_file,
              color: widget.configuration.secondaryTextColor)
          : Icon(Icons.image_not_supported,
              color: widget.configuration.secondaryTextColor);
    }

    return Stack(
      alignment: Alignment.topRight,
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              widget.column.imageBorderRadius ?? (isFile ? 0 : 8),
            ),
            child: isFile
                ? const Icon(Icons.insert_drive_file, size: 30)
                : Image.network(
                    widget.value.toString(),
                    errorBuilder: (ctx, err, stack) =>
                        const Icon(Icons.broken_image),
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        if (canEdit && widget.isEditing)
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.cancel, color: Colors.red, size: 16),
              onPressed: () =>
                  widget.onValueChange?.call(widget.column.key, null),
            ),
          ),
        if (canEdit && widget.isEditing)
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.edit, color: Colors.blue, size: 16),
              onPressed: () => isFile ? _pickFile() : _pickImage(),
            ),
          ),
      ],
    );
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
    return MenuAnchor(
      controller: _menuController,
      alignmentOffset: const Offset(-215, 0),
      style: MenuStyle(
        backgroundColor: MaterialStateProperty.all(Colors.transparent),
        surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
        elevation: MaterialStateProperty.all(0),
        padding: MaterialStateProperty.all(EdgeInsets.zero),
      ),
      builder: (context, controller, child) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              // Automatically detect opening direction based on screen space
              final RenderBox? box = context.findRenderObject() as RenderBox?;
              if (box != null) {
                final position = box.localToGlobal(Offset.zero);
                final screenHeight = MediaQuery.of(context).size.height;
                // If space below is less than 250px, open above
                setState(() {
                  _menuOpenedAbove = (screenHeight - position.dy <
                      widget.configuration.rowHeight * 4);
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
              alignment:
                  _menuOpenedAbove ? Alignment.bottomRight : Alignment.topRight,
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Material(
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.5),
            shape: _ArrowShape(
              arrowOnTop: !_menuOpenedAbove,
              configuration: widget.configuration,
            ),
            color: widget.configuration.menuBackgroundColor ?? Colors.white,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 20,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Delete the row',
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
                    padding: const EdgeInsets.only(left: 28.0),
                    child: Text(
                      'Are you sure to delete this row?',
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
                        height: 28,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            side: BorderSide(
                              color: widget.configuration.inputBorderColor,
                            ),
                            backgroundColor:
                                widget.configuration.gridBackgroundColor,
                            foregroundColor:
                                widget.configuration.rowForegroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          onPressed: () {
                            _menuController.close();
                          },
                          child: const Text('No'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 28,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            backgroundColor: widget.configuration.primaryColor,
                            foregroundColor:
                                widget.configuration.primaryForegroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          onPressed: () async {
                            _menuController.close();
                            final onDelete = widget.column.onDelete;
                            if (onDelete != null) {
                              await onDelete(widget.row);
                            }
                          },
                          child: const Text('Yes'),
                        ),
                      ),
                    ],
                  ),
                ],
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
    const double arrowWidth = 12.0;
    const double arrowHeight = 8.0;
    const double arrowOffset = 18.0;
    const double radius = 8.0;

    if (arrowOnTop) {
      // Arrow points UP at the top of the shape
      final r = ui.Rect.fromLTRB(
        rect.left,
        rect.top + arrowHeight,
        rect.right - arrowWidth,
        rect.bottom,
      );

      return ui.Path()
        ..moveTo(r.left + radius, r.top)
        ..lineTo(r.right - arrowOffset - arrowWidth, r.top)
        // Arrow up
        ..lineTo(r.right - arrowOffset - (arrowWidth / 2), rect.top)
        ..lineTo(r.right - arrowOffset, r.top)
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
      // Arrow points DOWN at the bottom of the shape
      final r = ui.Rect.fromLTRB(
        rect.left,
        rect.top,
        rect.right - arrowWidth,
        rect.bottom - arrowHeight,
      );

      return ui.Path()
        ..moveTo(r.left + radius, r.top)
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
        // Bottom line until arrow
        ..lineTo(r.right - arrowOffset, r.bottom)
        // Arrow down
        ..lineTo(r.right - arrowOffset - (arrowWidth / 2), rect.bottom)
        // Arrow back up
        ..lineTo(r.right - arrowOffset - arrowWidth, r.bottom)
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
      ..color = configuration.rowBorderColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(getOuterPath(rect, textDirection: textDirection), paint);
  }

  @override
  ShapeBorder scale(double t) =>
      _ArrowShape(arrowOnTop: arrowOnTop, configuration: configuration);
}
