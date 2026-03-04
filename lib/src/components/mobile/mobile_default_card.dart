import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:om_data_grid/src/components/grid_substring_highlight.dart';
import 'package:om_data_grid/src/enums/mobile_view_type_enum.dart';
import 'package:om_data_grid/src/models/datagrid_configuration.dart';
import 'package:om_data_grid/src/models/grid_column_model.dart';
import 'package:om_data_grid/src/enums/grid_row_type_enum.dart';
import 'package:om_data_grid/src/utils/cell_formatters.dart';
import 'package:om_data_grid/src/utils/general_helpers.dart';

/// The default card widget rendered for each row in the mobile data grid when
/// no custom [cardBuilder] is provided.
///
/// Displays each visible column as a `label: value` row inside a card.
class OmMobileDefaultCard extends StatelessWidget {
  final Map<String, dynamic> row;
  final List<OmGridColumnModel> columns;
  final OmDataGridConfiguration configuration;
  final OmMobileViewType viewType;
  final bool isSelected;
  final VoidCallback? onTap;
  final void Function(Map<String, dynamic> row)? onLongPress;

  /// Active global search term. When non-empty the matching substring inside
  /// each cell value is highlighted with the primary colour.
  final String searchTerm;

  const OmMobileDefaultCard({
    super.key,
    required this.row,
    required this.columns,
    required this.configuration,
    required this.viewType,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
    this.searchTerm = '',
  });

  @override
  Widget build(BuildContext context) {
    final config = configuration;
    final primary = config.primaryColor;
    final bgColor = isSelected
        ? config.selectedRowColor.withOpacity(0.12)
        : config.rowBackgroundColor;
    final borderColor = isSelected
        ? primary.withOpacity(0.5)
        : config.rowBorderColor.withOpacity(0.4);

    if (viewType == OmMobileViewType.compact) {
      return _buildCompactTile(bgColor, borderColor, primary);
    }

    if (viewType == OmMobileViewType.grid) {
      return _buildGridCard(bgColor, borderColor, primary);
    }

    return _buildListCard(bgColor, borderColor, primary);
  }

  // ── List view ─────────────────────────────────────────────────────────────

  Widget _buildListCard(Color bgColor, Color borderColor, Color primary) {
    final visibleCols = _visibleColumns;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress == null ? null : () => onLongPress!(row),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selection indicator bar
            if (isSelected)
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(14)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                children: visibleCols.asMap().entries.map((entry) {
                  final col = entry.value;
                  final isLast = entry.key == visibleCols.length - 1;
                  final value = row[col.key];
                  final display =
                      omMobileCellDisplay(value, col, configuration);

                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Label
                          SizedBox(
                            width: 110,
                            child: Text(
                              col.column.title,
                              style: TextStyle(
                                fontSize: 12,
                                color: configuration.secondaryTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Value
                          Expanded(
                            child: _highlighted(
                              display,
                              TextStyle(
                                fontSize: 13,
                                color: configuration.rowForegroundColor,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                      if (!isLast) ...[
                        const SizedBox(height: 6),
                        Divider(
                          height: 1,
                          color: configuration.rowBorderColor.withOpacity(0.3),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Grid (2-col) view ─────────────────────────────────────────────────────

  Widget _buildGridCard(Color bgColor, Color borderColor, Color primary) {
    final visibleCols = _visibleColumns.take(4).toList(); // show first 4 fields
    final firstCol = _visibleColumns.isNotEmpty ? _visibleColumns.first : null;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress == null ? null : () => onLongPress!(row),
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colour accent top bar
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: isSelected ? primary : primary.withOpacity(0.3),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title field
                  if (firstCol != null) ...[
                    _highlighted(
                      omMobileCellDisplay(
                          row[firstCol.key], firstCol, configuration),
                      TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: configuration.rowForegroundColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Other fields (skip first)
                  ...visibleCols.skip(firstCol != null ? 1 : 0).map((col) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${col.column.title}: ',
                            style: TextStyle(
                              fontSize: 11,
                              color: configuration.secondaryTextColor,
                            ),
                          ),
                          Expanded(
                            child: _highlighted(
                              omMobileCellDisplay(
                                  row[col.key], col, configuration),
                              TextStyle(
                                fontSize: 11,
                                color: configuration.rowForegroundColor,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Compact tile ──────────────────────────────────────────────────────────

  Widget _buildCompactTile(Color bgColor, Color borderColor, Color primary) {
    final firstCol = _visibleColumns.isNotEmpty ? _visibleColumns.first : null;
    final secondCol = _visibleColumns.length > 1 ? _visibleColumns[1] : null;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress == null ? null : () => onLongPress!(row),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: BorderDirectional(
            bottom: BorderSide(
              color: configuration.rowBorderColor.withOpacity(0.2),
            ),
            start: isSelected
                ? BorderSide(color: primary, width: 3)
                : BorderSide.none,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Colored circle avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: primary.withOpacity(isSelected ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? Iconsax.tick_circle : Iconsax.document_text,
                size: 18,
                color: primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (firstCol != null)
                    _highlighted(
                      omMobileCellDisplay(
                          row[firstCol.key], firstCol, configuration),
                      TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: configuration.rowForegroundColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (secondCol != null)
                    _highlighted(
                      omMobileCellDisplay(
                          row[secondCol.key], secondCol, configuration),
                      TextStyle(
                        fontSize: 12,
                        color: configuration.secondaryTextColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_right_3,
              size: 16,
              color: configuration.secondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }

  List<OmGridColumnModel> get _visibleColumns => columns
      .where((c) =>
          c.isVisible &&
          c.key != '__reorder_column__' &&
          c.column.key.isNotEmpty)
      .toList();

  /// Returns a [GridSubstringHighlight] when [searchTerm] is active,
  /// otherwise a plain [Text].
  Widget _highlighted(
    String display,
    TextStyle style, {
    int? maxLines,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    final term = searchTerm.trim();
    if (term.isEmpty) {
      return Text(
        display,
        style: style,
        overflow: overflow,
        maxLines: maxLines,
      );
    }
    final highlightStyle = style.copyWith(
      fontWeight: FontWeight.bold,
      backgroundColor: configuration.primaryColor.withOpacity(0.28),
    );
    return GridSubstringHighlight(
      text: display,
      terms: [term],
      textStyle: style,
      textStyleHighlight: highlightStyle,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}

/// A shimmer/skeleton placeholder that mimics a card.
class OmMobileSkeletonCard extends StatelessWidget {
  final OmMobileViewType viewType;

  const OmMobileSkeletonCard({super.key, required this.viewType});

  @override
  Widget build(BuildContext context) {
    if (viewType == OmMobileViewType.compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _Shimmer(width: 36, height: 36, borderRadius: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Shimmer(width: double.infinity, height: 14, borderRadius: 6),
                  const SizedBox(height: 6),
                  _Shimmer(width: 120, height: 11, borderRadius: 6),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (viewType == OmMobileViewType.grid) {
      return Container(
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[200]!),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Shimmer(width: double.infinity, height: 14, borderRadius: 6),
            const SizedBox(height: 8),
            _Shimmer(width: double.infinity, height: 11, borderRadius: 6),
            const SizedBox(height: 4),
            _Shimmer(width: 80, height: 11, borderRadius: 6),
          ],
        ),
      );
    }

    // List view
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        children: List.generate(
          3,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                _Shimmer(width: 90, height: 12, borderRadius: 6),
                const SizedBox(width: 8),
                Expanded(
                  child: _Shimmer(
                    width: double.infinity,
                    height: 12,
                    borderRadius: 6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A simple animated shimmer block.
class _Shimmer extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _Shimmer({
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(_animation.value * 0.3),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper: format a cell value for display in mobile cards
// ---------------------------------------------------------------------------

String omMobileCellDisplay(
  dynamic value,
  OmGridColumnModel col,
  OmDataGridConfiguration configuration,
) {
  if (value == null) return '\u2500';

  final labels = configuration.labels;

  switch (col.type) {
    case OmGridRowTypeEnum.integer:
      final num? n = num.tryParse(value.toString());
      if (n == null) return value.toString();
      return OmGridCellFormatters.formatNumber(
        value: n.toDouble(),
        digits: 0,
        thousandsSeparator: col.thousandsSeparator,
        decimalSeparator: col.decimalSeparator,
      );

    case OmGridRowTypeEnum.double:
      final num? n = num.tryParse(value.toString());
      if (n == null) return value.toString();
      return OmGridCellFormatters.formatNumber(
        value: n.toDouble(),
        digits: 2,
        thousandsSeparator: col.thousandsSeparator,
        decimalSeparator: col.decimalSeparator,
      );

    case OmGridRowTypeEnum.date:
    case OmGridRowTypeEnum.dateTime:
    case OmGridRowTypeEnum.time:
      final bool isTime = col.type == OmGridRowTypeEnum.time;
      final DateTime? date =
          OmGridDateTimeUtils.tryParse(value, isTime: isTime);
      if (date == null) return value.toString();
      return OmGridCellConstants.defaultDateFormatter.format(date);

    case OmGridRowTypeEnum.iosSwitch:
      final bool b =
          value is bool ? value : value.toString().toLowerCase() == 'true';
      return b ? labels.trueText : labels.falseText;

    case OmGridRowTypeEnum.comboBox:
      final val = value.toString();
      final items = col.comboBoxSettings?.items ?? [];
      final matches = items.where((o) => o.value == val).toList();
      return matches.isNotEmpty ? matches.first.text : val;

    default:
      return value.toString();
  }
}
