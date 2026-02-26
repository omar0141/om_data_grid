## 0.0.18

- **Multi-Language Support**: Added comprehensive localization support for 11 languages (English, Arabic, French, Turkish, Hindi, Spanish, Japanese, Chinese, Russian, German, Portuguese) via `OmDataGridLabels` named constructors.
- **Enhanced Chart Localization**: Fully localized chart UI, including settings panels, tooltips, and export dialogs.
- **Model-Driven Strings**: Refactored all hardcoded strings to use the central `OmDataGridLabels` configuration, enabling complete customization.

## 0.0.17

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
