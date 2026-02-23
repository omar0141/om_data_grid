/// Defines the type of data or widget to render in a grid cell.
enum OmGridRowTypeEnum {
  /// Display text content.
  text,

  /// Display a double precision number.
  double,

  /// Display an integer number.
  integer,

  /// Display a combo box (dropdown) for selection.
  comboBox,

  /// Display a file picker or file info.
  file,

  /// Display an image.
  image,

  /// Display a clickable button.
  button,

  /// Display a custom widget.
  widget,

  /// Display code snippet.
  code,

  /// Display a handle for reordering rows.
  reordable,

  /// Display an iOS-style switch.
  iosSwitch,

  /// Display a date.
  date,

  /// Display a time.
  time,

  /// Display a date and time.
  dateTime,

  /// Display multiple images.
  multiImage,

  /// Display multiple files.
  multiFile,

  /// Display a delete action/button.
  delete,

  /// Display a context menu trigger.
  contextMenu,

  /// Display a state indicator.
  state,
}
