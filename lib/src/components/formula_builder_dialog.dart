import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:om_data_grid/src/models/grid_column_model.dart';
import 'package:om_data_grid/src/utils/datagrid_controller.dart';

enum FormulaBlockType { column, operator, value }

class FormulaBlock {
  final String label;
  final String value;
  final FormulaBlockType type;

  FormulaBlock({required this.label, required this.value, required this.type});
}

class FormulaBuilderDialog extends StatefulWidget {
  final OmDataGridController controller;
  final OmGridColumnModel? existing;

  const FormulaBuilderDialog({
    super.key,
    required this.controller,
    this.existing,
  });

  @override
  State<FormulaBuilderDialog> createState() => _FormulaBuilderDialogState();
}

class _FormulaBuilderDialogState extends State<FormulaBuilderDialog> {
  late List<FormulaBlock> _blocks;
  late TextEditingController _titleController;
  late TextEditingController _advancedController;
  bool _isAdvancedMode = false;
  String? _titleError;

  bool get _isEditing =>
      widget.existing != null && widget.existing!.key.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existing?.column.title ?? "",
    );
    _advancedController = TextEditingController(
      text: widget.existing?.column.formula ?? "",
    );
    _blocks = _parseFormulaToBlocks(widget.existing?.column.formula ?? "");
  }

  List<FormulaBlock> _parseFormulaToBlocks(String formula) {
    if (formula.isEmpty) return [];

    final blocks = <FormulaBlock>[];
    final operators = ['+', '-', '*', '/', '(', ')'];

    // Sort columns by title length descending to match longest titles first
    final sortedCols =
        List<OmGridColumnModel>.from(widget.controller.columnModels)
          ..where((c) => !c.key.startsWith('__'))
          ..sort(
            (a, b) => b.column.title.length.compareTo(a.column.title.length),
          );

    String remaining = formula;

    while (remaining.isNotEmpty) {
      remaining = remaining.trimLeft();
      if (remaining.isEmpty) break;

      bool matched = false;

      // 1. Try matching column titles
      for (var col in sortedCols) {
        if (col.column.title.isNotEmpty &&
            remaining.startsWith(col.column.title)) {
          blocks.add(
            FormulaBlock(
              label: col.column.title,
              value: col.column.title,
              type: FormulaBlockType.column,
            ),
          );
          remaining = remaining.substring(col.column.title.length);
          matched = true;
          break;
        }
      }

      if (matched) continue;

      // 2. Try matching operators
      for (var op in operators) {
        if (remaining.startsWith(op)) {
          blocks.add(
            FormulaBlock(label: op, value: op, type: FormulaBlockType.operator),
          );
          remaining = remaining.substring(op.length);
          matched = true;
          break;
        }
      }

      if (matched) continue;

      // 3. Match values (numbers/text until next space or operator)
      final nextSpace = remaining.indexOf(' ');
      final nextOp = remaining
          .split('')
          .indexWhere((char) => operators.contains(char));

      int end;
      if (nextSpace == -1 && nextOp == -1) {
        end = remaining.length;
      } else if (nextSpace == -1) {
        end = nextOp;
      } else if (nextOp == -1) {
        end = nextSpace;
      } else {
        end = nextSpace < nextOp ? nextSpace : nextOp;
      }

      if (end > 0) {
        final val = remaining.substring(0, end);
        blocks.add(
          FormulaBlock(label: val, value: val, type: FormulaBlockType.value),
        );
        remaining = remaining.substring(end);
      } else {
        // Safety break if stuck
        remaining = remaining.substring(1);
      }
    }

    return blocks;
  }

  String _generateFormula() {
    if (_isAdvancedMode) return _advancedController.text;
    return _blocks.map((b) => b.value).join(" ");
  }

  void _addBlock(FormulaBlock block) {
    setState(() {
      _blocks.add(block);
      _advancedController.text = _generateFormula();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.controller.configuration.primaryColor;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor:
          widget.controller.configuration.dialogBackgroundColor ?? Colors.white,
      surfaceTintColor:
          widget.controller.configuration.dialogSurfaceTintColor ??
          Colors.white,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _isEditing ? Icons.edit_note : Icons.calculate_outlined,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _isEditing ? "Edit Equation" : "New Equation",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                "Advanced",
                style: TextStyle(
                  fontSize: 12,
                  color:
                      widget.controller.configuration.dialogTextColor ??
                      Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Transform.scale(
                scale: 0.7,
                child: CupertinoSwitch(
                  value: _isAdvancedMode,
                  activeColor: primaryColor,
                  onChanged: (val) {
                    setState(() {
                      if (val) {
                        _advancedController.text = _generateFormula();
                      }
                      _isAdvancedMode = val;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      content: SizedBox(
        width: 550,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                onChanged: (val) {
                  if (_titleError != null) {
                    setState(() => _titleError = null);
                  }
                },
                decoration: InputDecoration(
                  hintText: "Enter Column Display Name (e.g., Total Salary)",
                  errorText: _titleError,
                  prefixIcon: const Icon(Icons.title, size: 18),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Equation Builder",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_isAdvancedMode)
                TextField(
                  controller: _advancedController,
                  maxLines: 4,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                  decoration: InputDecoration(
                    hintText: "Enter your formula...",
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: primaryColor, width: 1.5),
                    ),
                  ),
                )
              else
                Container(
                  constraints: const BoxConstraints(minHeight: 120),
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _blocks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_chart,
                                color: Colors.grey.shade300,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Start building your equation by adding blocks below",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 10,
                          children: _blocks.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final block = entry.value;
                            return _buildDraggableBlock(block, idx);
                          }).toList(),
                        ),
                ),
              const SizedBox(height: 24),
              _buildSectionTitle("Operators"),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: ['+', '-', '*', '/', '(', ')'].map((op) {
                  return _buildToolChip(
                    label: op,
                    color: Colors.blue.shade100,
                    textColor: Colors.blue.shade800,
                    onTap: () => _addBlock(
                      FormulaBlock(
                        label: op,
                        value: op,
                        type: FormulaBlockType.operator,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle("Available Columns"),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.controller.columnModels
                    .where(
                      (c) =>
                          !c.key.startsWith('__') &&
                          c.key != widget.existing?.key,
                    )
                    .map((c) {
                      return _buildToolChip(
                        label: c.column.title,
                        color: primaryColor.withOpacity(0.05),
                        textColor: primaryColor,
                        onTap: () => _addBlock(
                          FormulaBlock(
                            label: c.column.title,
                            value: c.column.title,
                            type: FormulaBlockType.column,
                          ),
                        ),
                      );
                    })
                    .toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel", style: TextStyle(color: Colors.grey.shade600)),
        ),
        ElevatedButton(
          onPressed: () {
            final f = _generateFormula();
            final title = _titleController.text.trim();

            if (title.isEmpty) {
              setState(() => _titleError = "Title is required");
              return;
            }

            if (f.isNotEmpty) {
              if (_isEditing) {
                widget.controller.updateCalculatedColumn(
                  widget.existing!.key,
                  title,
                  f,
                );
              } else {
                widget.controller.addCalculatedColumn(title, f);
              }
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text(_isEditing ? "Update Column" : "Create Column"),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildToolChip({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: textColor.withOpacity(0.1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableBlock(FormulaBlock block, int index) {
    return Draggable<int>(
      data: index,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.8,
          child: _buildBlockItem(block, index, isDragging: true),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.2,
        child: _buildBlockItem(block, index),
      ),
      child: DragTarget<int>(
        onWillAccept: (data) => data != null && data != index,
        onAccept: (fromIndex) {
          setState(() {
            final item = _blocks.removeAt(fromIndex);
            _blocks.insert(index, item);
          });
        },
        builder: (context, candidateData, rejectedData) {
          return _buildBlockItem(
            block,
            index,
            isHighlighted: candidateData.isNotEmpty,
          );
        },
      ),
    );
  }

  Widget _buildBlockItem(
    FormulaBlock block,
    int index, {
    bool isDragging = false,
    bool isHighlighted = false,
  }) {
    final bool isColumn = block.type == FormulaBlockType.column;
    final bool isOp = block.type == FormulaBlockType.operator;
    final primaryColor = Theme.of(context).primaryColor;

    Color bgColor = isColumn
        ? primaryColor.withOpacity(0.08)
        : isOp
        ? Colors.orange.shade50
        : Colors.grey.shade50;
    Color textColor = isColumn
        ? primaryColor
        : isOp
        ? Colors.orange.shade800
        : Colors.black87;
    Color borderColor = isHighlighted
        ? primaryColor
        : (isDragging ? Colors.transparent : Colors.grey.shade300);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: isHighlighted ? 2 : 1),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isColumn) ...[
            Icon(
              Icons.table_chart_outlined,
              size: 14,
              color: textColor.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            block.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              setState(() {
                _blocks.removeAt(index);
              });
            },
            child: Icon(
              Icons.close,
              size: 14,
              color: textColor.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
