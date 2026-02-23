/// Defines the logical operator for combining filter conditions.
enum OmFilterOperator {
  /// All conditions must be met.
  and,

  /// At least one condition must be met.
  or,
}

/// Defines the type of condition for filtering.
enum OmFilterConditionType {
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
class OmFilterCondition {
  /// The type of comparison to perform.
  OmFilterConditionType type;

  /// The primary value for comparison.
  String value;

  /// The secondary value for comparison (used for 'between' type).
  String valueTo;

  /// Creates a new [OmFilterCondition].
  OmFilterCondition({
    this.type = OmFilterConditionType.contains,
    this.value = '',
    this.valueTo = '',
  });

  /// Converts this [OmFilterCondition] to a JSON map.
  Map<String, dynamic> toJson() => {
    'type': type.toString(),
    'value': value,
    'valueTo': valueTo,
  };

  /// Creates a [OmFilterCondition] from a JSON map.
  factory OmFilterCondition.fromJson(Map<String, dynamic> json) {
    return OmFilterCondition(
      type: OmFilterConditionType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => OmFilterConditionType.contains,
      ),
      value: json['value'] ?? '',
      valueTo: json['valueTo'] ?? '',
    );
  }
}

/// Model representing an advanced filter configuration.
///
/// Wraps multiple conditions and an operator to combine them.
class OmAdvancedFilterModel {
  /// The operator used to combine the conditions (AND/OR).
  OmFilterOperator operator;

  /// The list of conditions to evaluate.
  List<OmFilterCondition> conditions;

  /// Creates a new [OmAdvancedFilterModel].
  OmAdvancedFilterModel({
    this.operator = OmFilterOperator.and,
    List<OmFilterCondition>? conditions,
  }) : conditions = conditions ?? [];

  /// Converts this [OmAdvancedFilterModel] to a JSON map.
  Map<String, dynamic> toJson() => {
    'operator': operator.toString(),
    'conditions': conditions.map((e) => e.toJson()).toList(),
  };

  /// Creates an [OmAdvancedFilterModel] from a JSON map.
  factory OmAdvancedFilterModel.fromJson(Map<String, dynamic> json) {
    return OmAdvancedFilterModel(
      operator: OmFilterOperator.values.firstWhere(
        (e) => e.toString() == json['operator'],
        orElse: () => OmFilterOperator.and,
      ),
      conditions:
          (json['conditions'] as List?)
              ?.map((e) => OmFilterCondition.fromJson(e))
              .toList() ??
          [],
    );
  }
}
