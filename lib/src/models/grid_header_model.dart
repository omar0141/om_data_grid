/// Model representing a header in a combo box.
class OmComboBoxHeaderModel {
  /// The key identifier of the header.
  String? key;

  /// The display name of the header.
  String? name;

  /// The width of the header column.
  double? width;

  /// Mobile visibility flag.
  int? isMobile;

  /// Creates a [OmComboBoxHeaderModel].
  OmComboBoxHeaderModel({this.key, this.name, this.width, this.isMobile});

  /// Creates a [OmComboBoxHeaderModel] from JSON.
  OmComboBoxHeaderModel.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    name = json['name'];
    width = double.tryParse(json['width']?.toString() ?? '');
    isMobile = json['is_mobile'];
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['name'] = name;
    data['width'] = width;
    data['is_mobile'] = isMobile;
    return data;
  }
}
