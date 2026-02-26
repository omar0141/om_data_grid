import 'package:flutter/material.dart';
import '../utils/datagrid_controller.dart';

class OmColumnChooserPopup extends StatefulWidget {
  final OmDataGridController controller;
  final VoidCallback onClose;
  final Offset initialPosition;

  const OmColumnChooserPopup({
    super.key,
    required this.controller,
    required this.onClose,
    this.initialPosition = const Offset(200, 200),
  });

  @override
  State<OmColumnChooserPopup> createState() => _ColumnChooserPopupState();
}

class _ColumnChooserPopupState extends State<OmColumnChooserPopup> {
  late Offset _position;
  final double _width = 300;
  final double _height = 400;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    final configuration = widget.controller.configuration;

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        color: configuration.dialogBackgroundColor,
        child: Container(
          width: _width,
          height: _height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: configuration.gridBorderColor),
          ),
          child: Column(
            children: [
              // Header / Drag Handle
              GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _position += details.delta;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: configuration.primaryColor.withAlpha(15),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.view_column,
                        size: 20,
                        color: configuration.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        configuration.labels.columnChooserTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: configuration.dialogTextColor,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 20,
                          color: configuration.secondaryTextColor,
                        ),
                        onPressed: widget.onClose,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
              // Search or Filter can be added here
              Expanded(
                child: ListenableBuilder(
                  listenable: widget.controller,
                  builder: (context, child) {
                    final columns = widget.controller.columnModels;
                    return ReorderableListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: columns.length,
                      onReorder: (oldIndex, newIndex) {
                        widget.controller.reorderColumns(oldIndex, newIndex);
                      },
                      itemBuilder: (context, index) {
                        final column = columns[index];
                        return ListTile(
                          key: ValueKey(column.key),
                          dense: true,
                          leading: Checkbox(
                            activeColor:
                                widget.controller.configuration.primaryColor,
                            checkColor: widget.controller.configuration
                                .primaryForegroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            visualDensity: VisualDensity.compact,
                            value: column.isVisible,
                            onChanged: (val) {
                              widget.controller.toggleColumnVisibility(
                                column.key,
                                val ?? false,
                              );
                            },
                          ),
                          title: Text(
                            column.title,
                            style:
                                TextStyle(color: configuration.dialogTextColor),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => widget.controller.resetColumns(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: configuration.primaryColor,
                      foregroundColor: configuration.primaryForegroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(configuration.labels.resetDefaultLayout),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
