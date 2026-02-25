## 0.0.14

- **Cascading Theming System**: Simplified grid styling by allowing users to set base colors (`gridBackgroundColor`, `gridForegroundColor`, `gridBorderColor`, `primaryColor`) which automatically cascade to over 50+ individual UI components.
- **Global Typography**: Added `gridFontFamily` to apply a consistent font across rows, headers, and grouping panels.
- **Modern Default Palette**: Updated default colors to a clean, professional Slate/Gray design.
- Full control: You can still override any specific property while using the new base theme fallbacks.

## 0.0.13

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
