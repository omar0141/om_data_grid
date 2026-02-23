import 'package:om_data_grid/src/components/grid_filter/grid_filter_body.dart';
import 'package:om_data_grid/src/models/datagrid_configuration.dart';
import 'package:om_data_grid/src/models/grid_column_model.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class GridFilter extends StatelessWidget {
  const GridFilter({
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: PopupMenuButton(
        position: PopupMenuPosition.under,
        padding: const EdgeInsets.only(top: -10),
        color: configuration.filterPopupBackgroundColor,
        shadowColor: Colors.black,
        tooltip: "",
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem(
              enabled: false,
              child: SizedBox(
                height: 480,
                width: 250,
                child: GridFilterBody(
                  orgData: orgData,
                  dataSource: dataSource,
                  onSearch: onSearch,
                  attributes: attributes,
                  allAttributes: allAttributes,
                  configuration: configuration,
                  globalSearchText: globalSearchText,
                ),
              ),
            ),
          ];
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Iconsax.filter_copy,
              size: 18,
              color: configuration.filterIconColor,
            ),
            if (attributes.isFiltered)
              PositionedDirectional(
                top: -1,
                start: -1,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: configuration.headerBackgroundColor,
                    ),
                    borderRadius: BorderRadius.circular(5),
                    color: configuration.filterIconColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
