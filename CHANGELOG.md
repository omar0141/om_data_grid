## 0.0.23

- **RTL Dragging Support**: Fixed an issue where dragging popups (`OmChartPopup` and `OmColumnChooserPopup`) moved in the opposite direction when the application was in RTL (Right-to-Left) mode.

## 0.0.22

- **Universal `widgetBuilder`**: The `widgetBuilder` callback on `OmGridColumn` now works for **all** column types, not just `widget`. The callback signature has been updated to `Widget Function(dynamic value, Map<String, dynamic> row, Widget defaultWidget)`. The third argument is the default widget the grid would normally render, allowing you to return it unchanged, wrap it, or replace it entirely based on row values.

## 0.0.21

- **Fix Phantom Padding**: Resolved an issue where a blank 12px gap appeared on the right side of the grid when vertical scrolling was not needed. The vertical scrollbar strip now collapses to zero width when hidden, and the available content width is recalculated accordingly.

## 0.0.20

- **Scrollbar Overhaul**: Fixed vertical scrollbar always appearing at the right edge of scrollable content instead of the viewport edge. The vertical scrollbar is now pinned to the visible viewport and is always accessible without horizontal scrolling.
- **Dual Custom Scrollbars**: Replaced Flutter's built-in `Scrollbar`/`RawScrollbar` with custom-painted scrollbars (`CustomPainter` + `GestureDetector`) for both axes, eliminating web/wasm `TypeErrorImpl` crashes caused by JS-null coercion on `ScrollPosition` properties.
- **Horizontal Scrollbar at Bottom**: Horizontal scrollbar now renders below the grid body (not at the header), matching standard data grid UX.
- **Auto-hide Scrollbars**: Both scrollbars automatically hide when content fits within the viewport (threshold: `maxScrollExtent < 15px` for horizontal).
- **Suppressed Duplicate Scrollbars**: Wrapped `OmGridBody` with `ScrollConfiguration(scrollbars: false)` to prevent Flutter's desktop `MaterialScrollBehavior` from injecting a second auto-scrollbar on top of the custom one.

## 0.0.19

- **Filter Normalization**: Fixed an issue where boolean/iosSwitch columns displayed duplicate "false" values in the filter checklist. Improved value normalization for truthy and falsy values to ensure consistent filtering behavior.

## 0.0.18

- Added additive search behavior to the grid filter popup, allowing the user to search for and select new items without losing their previous manual selections.

## 0.0.16

- fix delete pop confirm border color

## 0.0.15

- **Unified Theme Integration**: Applied the `OmDataGridTheme` system to all popups and dialogs, including `ColumnChooserPopup`, `FormulaBuilderDialog`, and `DeleteConfirmation`.
- **Dark Mode Optimization**: Enhanced visibility and contrast for input fields and search bars when using dark themes.
- **Improved Positioning**: Fixed context menu positioning to accurately track cursor and long-press coordinates.
- **Bug Fixes**: Resolved property naming inconsistencies and missing asset errors in the chart sidebar.

## 0.0.14

- **Cascading Theming System**: Simplified grid styling by allowing users to set base colors (`gridBackgroundColor`, `gridForegroundColor`, `gridBorderColor`, `primaryColor`) which automatically cascade to over 50+ individual UI components.

- change style of the title in quick filter bar

## 0.0.12

- Replaced `open_file_plus` with `url_launcher` to improve platform support.
- Replaced `file_picker` with `file_selector` for better Wasm compatibility.
- Migrated from `universal_html` to `package:web` for full Wasm support.
- Improved file export and viewing logic across all platforms.

## 0.0.11

- update min dart sdk to 2.19

## 0.0.10

- Replace `open_file_plus` with `url_launcher` for better desktop support.
- Replace `file_picker` with `file_selector` for improved cross-platform compatibility.
- Fix Wasm compatibility by abstracting `dart:isolate` usage.
- Improve platform-specific code isolation.

## 0.0.8

- Fix platform support issues for Android, iOS, Windows, Linux, macOS, and Web.
- Improve Web compatibility by isolating `dart:io` and `open_file_plus` logic.
- Isolate `file_picker` usage to resolve analyzer warnings on some platforms.

## 0.0.7

- update class names

## 0.0.6

- update to last versions of packages

## 0.0.5

- Fix static analysis issues.
- Update documentation.

## 0.0.4

- Improve grid performance.
- Fix minor bugs in filtering.

## 0.0.1

- Initial release of `om_data_grid`.
- Core DataGrid implementation.
- Features included: filtering, sorting, grouping, charting, and more.
