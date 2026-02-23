enum FilterOperator { and, or }

enum FilterConditionType {
  equals,
  notEqual,
  contains,
  notContains,
  startsWith,
  endsWith,
  greaterThan,
  lessThan,
  greaterThanOrEqual,
  lessThanOrEqual,
  empty,
  notEmpty,
  between,
}

class FilterCondition {
  FilterConditionType type;
  String value;
  String valueTo;

  FilterCondition({
    this.type = FilterConditionType.contains,
    this.value = '',
    this.valueTo = '',
  });

  Map<String, dynamic> toJson() => {
    'type': type.toString(),
    'value': value,
    'valueTo': valueTo,
  };

  factory FilterCondition.fromJson(Map<String, dynamic> json) {
    return FilterCondition(
      type: FilterConditionType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => FilterConditionType.contains,
      ),
      value: json['value'] ?? '',
      valueTo: json['valueTo'] ?? '',
    );
  }
}

class AdvancedFilterModel {
  FilterOperator operator;
  List<FilterCondition> conditions;

  AdvancedFilterModel({
    this.operator = FilterOperator.and,
    List<FilterCondition>? conditions,
  }) : conditions = conditions ?? [];

  Map<String, dynamic> toJson() => {
    'operator': operator.toString(),
    'conditions': conditions.map((e) => e.toJson()).toList(),
  };

  factory AdvancedFilterModel.fromJson(Map<String, dynamic> json) {
    return AdvancedFilterModel(
      operator: FilterOperator.values.firstWhere(
        (e) => e.toString() == json['operator'],
        orElse: () => FilterOperator.and,
      ),
      conditions:
          (json['conditions'] as List?)
              ?.map((e) => FilterCondition.fromJson(e))
              .toList() ??
          [],
    );
  }
}
