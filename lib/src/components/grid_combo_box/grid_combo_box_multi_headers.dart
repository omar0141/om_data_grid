import 'package:om_data_grid/src/models/datagrid_configuration.dart';
import 'package:om_data_grid/src/models/grid_combo_box_item.dart';
import 'package:om_data_grid/src/models/grid_header_model.dart';
import 'package:om_data_grid/src/utils/general_helpers.dart';
import 'package:om_data_grid/src/utils/platform_helper.dart';
import 'package:flutter/material.dart';
import '../grid_substring_highlight.dart';

class GridComboxBoxMultiColumnsHeaders extends StatelessWidget {
  const GridComboxBoxMultiColumnsHeaders({
    super.key,
    required this.headers,
    required this.multi,
    required this.configuration,
  });

  final List<OmComboBoxHeaderModel> headers;
  final bool multi;
  final OmDataGridConfiguration configuration;

  @override
  Widget build(BuildContext context) {
    List<OmComboBoxHeaderModel> myheaders = headers;
    if (OmPlatformHelper.isDesktop == false) {
      myheaders.removeWhere((e) => e.isMobile != 1);
    }
    return Container(
      margin: const EdgeInsetsDirectional.only(start: 8, end: 8, top: 8),
      decoration: BoxDecoration(
        color: configuration.primaryColor.withOpacityNew(0.1),
        border: Border(
          bottom: BorderSide(color: configuration.gridBorderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (multi) const SizedBox(width: 50),
          ...myheaders.map((header) {
            final headerWidget = Container(
              width: header.width,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                header.name ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: configuration.headerForegroundColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );

            return header.width == null
                ? Expanded(child: headerWidget)
                : headerWidget;
          }),
        ],
      ),
    );
  }
}

class ComboxBoxMultiColumnsRows extends StatelessWidget {
  const ComboxBoxMultiColumnsRows({
    super.key,
    required this.item,
    required this.headers,
    required this.searchController,
    required this.selected,
    required this.configuration,
  });

  final OmGridComboBoxItem item;
  final List<OmComboBoxHeaderModel> headers;
  final TextEditingController searchController;
  final bool selected;
  final OmDataGridConfiguration configuration;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Row(children: _buildRowCells(item)),
    );
  }

  List<Widget> _buildRowCells(OmGridComboBoxItem item) {
    final Map<String, dynamic> itemData = item.extraData;
    List<OmComboBoxHeaderModel> myheaders = headers;
    if (OmPlatformHelper.isDesktop == false) {
      myheaders.removeWhere((e) => e.isMobile != 1);
    }
    return myheaders.map((header) {
      int i = myheaders.indexOf(header);
      final value = itemData[header.key] ?? '';
      final cellWidget = Container(
        decoration: BoxDecoration(
          color:
              selected ? configuration.primaryColor.withOpacityNew(0.1) : null,
        ),
        width: header.width,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            if (i == 0) ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 4,
                height: selected ? 18 : 0,
                decoration: BoxDecoration(
                  color: configuration.primaryColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: searchController.text.isEmpty
                  ? Text(
                      value.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: configuration.secondaryTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : GridSubstringHighlight(
                      text: value.toString(),
                      term: searchController.text,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textStyle: TextStyle(
                        fontSize: 14,
                        color: configuration.secondaryTextColor,
                      ),
                      textStyleHighlight: TextStyle(
                        fontSize: 14,
                        color: configuration.secondaryTextColor,
                        fontWeight: FontWeight.bold,
                        backgroundColor: configuration.primaryColor.withOpacity(
                          0.3,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      );

      return header.width == null ? Expanded(child: cellWidget) : cellWidget;
    }).toList();
  }
}
