import 'package:flutter/material.dart';
import 'package:om_data_grid/src/components/grid_filter/grid_filter_body.dart';
import 'package:om_data_grid/src/models/datagrid_configuration.dart';
import 'package:om_data_grid/src/models/grid_column_model.dart';

/// Full-screen two-level filter page.
///
/// Level 1 – column list with active-filter indicators.
/// Level 2 – per-column [GridFilterBody] pushed on tap.
///
/// Use the static [OmMobileFilterSheet.show] helper to open it from any
/// widget without embedding it inside the data grid:
///
/// ```dart
/// OmMobileFilterSheet.show(
///   context: context,
///   columns: columns,
///   data: data,
///   filteredData: filteredData,
///   configuration: config,
///   onSearch: (result) { /* apply new data */ },
/// );
/// ```
class OmMobileFilterSheet extends StatefulWidget {
  final List<OmGridColumnModel> columns;
  final List<Map<String, dynamic>> data;
  final List<Map<String, dynamic>> filteredData;
  final OmDataGridConfiguration configuration;
  final void Function(List<dynamic>) onSearch;
  final String? globalSearchText;

  const OmMobileFilterSheet({
    super.key,
    required this.columns,
    required this.data,
    required this.filteredData,
    required this.configuration,
    required this.onSearch,
    this.globalSearchText,
  });

  /// Opens as a full-screen [MaterialPageRoute].
  static Future<void> show({
    required BuildContext context,
    required List<OmGridColumnModel> columns,
    required List<Map<String, dynamic>> data,
    required List<Map<String, dynamic>> filteredData,
    required OmDataGridConfiguration configuration,
    required void Function(List<dynamic>) onSearch,
    String? globalSearchText,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => OmMobileFilterSheet(
          columns: columns,
          data: data,
          filteredData: filteredData,
          configuration: configuration,
          onSearch: onSearch,
          globalSearchText: globalSearchText,
        ),
      ),
    );
  }

  @override
  State<OmMobileFilterSheet> createState() => _OmMobileFilterSheetState();
}

class _OmMobileFilterSheetState extends State<OmMobileFilterSheet> {
  // Bump to force a rebuild after returning from the detail page so that
  // active-filter indicators update.
  int _refreshKey = 0;

  List<OmGridColumnModel> get _filterableColumns => widget.columns
      .where((c) =>
          c.isVisible &&
          c.column.allowFiltering &&
          c.key != '__reorder_column__')
      .toList();

  int get _totalActiveFilters =>
      widget.columns.where((c) => c.isFiltered).length;

  @override
  Widget build(BuildContext context) {
    final config = widget.configuration;
    final bg = config.menuBackgroundColor ?? Colors.white;
    final primary = config.primaryColor;
    final textColor = config.gridForegroundColor;
    final secondaryText = config.secondaryTextColor;
    final labels = config.labels;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          labels.options,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        leading: const SizedBox.shrink(),
        actions: [
          IconButton(
            icon: Icon(Icons.close, size: 22, color: secondaryText),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: config.gridBorderColor),
        ),
      ),
      body: _filterableColumns.isEmpty
          ? Center(
              child: Text(
                labels.noData,
                style: TextStyle(color: secondaryText, fontSize: 15),
              ),
            )
          : KeyedSubtree(
              key: ValueKey(_refreshKey),
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 110),
                itemCount: _filterableColumns.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: config.gridBorderColor.withOpacity(0.35),
                ),
                itemBuilder: (context, index) {
                  final col = _filterableColumns[index];
                  final isFiltered = col.isFiltered;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => _OmFilterDetailPage(
                            column: col,
                            allColumns: widget.columns,
                            data: widget.data,
                            filteredData: widget.filteredData,
                            configuration: config,
                            onSearch: widget.onSearch,
                            globalSearchText: widget.globalSearchText,
                          ),
                        ),
                      );
                      setState(() => _refreshKey++);
                    },
                    title: Text(
                      col.column.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            isFiltered ? FontWeight.w600 : FontWeight.w500,
                        color: isFiltered ? primary : textColor,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isFiltered)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 22,
                          color: secondaryText,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
      bottomNavigationBar: _buildBottomBar(
        context,
        primary,
        bg,
        config,
        _totalActiveFilters,
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, Color primary, Color bg,
      OmDataGridConfiguration config, int activeCount) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          top: BorderSide(color: config.gridBorderColor.withOpacity(0.4)),
        ),
      ),
      child: Row(
        children: [
          if (activeCount > 0) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  for (final col in widget.columns) {
                    col.filter = false;
                    col.quickFilterText = null;
                    col.notSelectedFilterData = null;
                    col.advancedFilter = null;
                  }
                  widget.onSearch(widget.data);
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                label: Text(config.labels.clearFilter),
                style: OutlinedButton.styleFrom(
                  foregroundColor: config.errorColor,
                  side: BorderSide(color: config.errorColor.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: config.primaryForegroundColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.filter_alt_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    activeCount > 0
                        ? '${config.labels.apply} ($activeCount)'
                        : config.labels.apply,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Level-2: per-column detail page
// ---------------------------------------------------------------------------

class _OmFilterDetailPage extends StatelessWidget {
  final OmGridColumnModel column;
  final List<OmGridColumnModel> allColumns;
  final List<Map<String, dynamic>> data;
  final List<Map<String, dynamic>> filteredData;
  final OmDataGridConfiguration configuration;
  final void Function(List<dynamic>) onSearch;
  final String? globalSearchText;

  const _OmFilterDetailPage({
    required this.column,
    required this.allColumns,
    required this.data,
    required this.filteredData,
    required this.configuration,
    required this.onSearch,
    this.globalSearchText,
  });

  @override
  Widget build(BuildContext context) {
    final config = configuration;
    final bg = config.menuBackgroundColor ?? Colors.white;
    final textColor = config.gridForegroundColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: textColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          column.column.title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: config.gridBorderColor),
        ),
      ),
      body: GridFilterBody(
        orgData: data,
        dataSource: filteredData,
        onSearch: onSearch,
        attributes: column,
        allAttributes: allColumns,
        configuration: configuration,
        globalSearchText: globalSearchText,
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      ),
    );
  }
}
