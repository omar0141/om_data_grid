class ComboBoxHeaderModel {
  String? key;
  String? name;
  double? width;
  int? isMobile;

  ComboBoxHeaderModel({this.key, this.name, this.width, this.isMobile});

  ComboBoxHeaderModel.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    name = json['name'];
    width = double.tryParse(json['width']?.toString() ?? '');
    isMobile = json['is_mobile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['name'] = name;
    data['width'] = width;
    data['is_mobile'] = isMobile;
    return data;
  }
}
