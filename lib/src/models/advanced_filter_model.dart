/// Defines the logical operator for combining filter conditions.
enum FilterOperator {
  /// All conditions must be met.
  and,

  /// At least one condition must be met.
  or,
}

/// Defines the type of condition for filtering.
enum FilterConditionType {
  /// The value equals the filter criteria.
  equals,

  /// The value does not equal the filter criteria.
  notEqual,

  /// The value contains the filter criteria.
  contains,

  /// The value does not contain the filter criteria.
  notContains,

  /// The value starts with the filter criteria.
  startsWith,

  /// The value ends with the filter criteria.
  endsWith,

  /// The value is greater than the filter criteria.
  greaterThan,

  /// The value is less than the filter criteria.
  lessThan,

  /// The value is greater than or equal to the filter criteria.
  greaterThanOrEqual,

  /// The value is less than or equal to the filter criteria.
  lessThanOrEqual,

  /// The value is empty.
  empty,

  /// The value is not empty.
  notEmpty,

  /// The value is between two criteria.
  between,
}

/// Represents a single condition within an advanced filter.
class FilterCondition {
  /// The type of comparison to perform.
  FilterConditionType type;

  /// The primary value for comparison.
  String value;

  /// The secondary value for comparison (used for 'between' type).
  String valueTo;

  /// Creates a new [FilterCondition].
  FilterCondition({
    this.type = FilterConditionType.contains,
    this.value = '',
    this.valueTo = '',
  });

  /// Converts this [FilterCondition] to a JSON map.
  Map<String, dynamic> toJson() => {
    'type': type.toString(),
    'value': value,
    'valueTo': valueTo,
  };

  /// Creates a [FilterCondition] from a JSON map.
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

/// Model representing an advanced filter configuration.
///
/// Wraps multiple conditions and an operator to combine them.
class AdvancedFilterModel {
  /// The operator used to combine the conditions (AND/OR).
  FilterOperator operator;

  /// The list of conditions to evaluate.
  List<FilterCondition> conditions;

  /// Creates a new [AdvancedFilterModel].
  AdvancedFilterModel({
    this.operator = FilterOperator.and,
    List<FilterCondition>? conditions,
  }) : conditions = conditions ?? [];

  /// Converts this [AdvancedFilterModel] to a JSON map.
  Map<String, dynamic> toJson() => {
    'operator': operator.toString(),
    'conditions': conditions.map((e) => e.toJson()).toList(),
  };

  /// Creates an [AdvancedFilterModel] from a JSON map.
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
