import 'package:flutter_riverpod/flutter_riverpod.dart';

class BusinessProgressState {
  final String? businessId;
  final int percentage;
  final Map<String, bool> fields;

  const BusinessProgressState({
    this.businessId,
    this.percentage = 0,
    this.fields = const {},
  });

  BusinessProgressState copyWith({
    String? businessId,
    int? percentage,
    Map<String, bool>? fields,
  }) {
    return BusinessProgressState(
      businessId: businessId ?? this.businessId,
      percentage: percentage ?? this.percentage,
      fields: fields ?? this.fields,
    );
  }
}

class BusinessProgressNotifier extends StateNotifier<BusinessProgressState> {
  BusinessProgressNotifier() : super(const BusinessProgressState());

  static const List<String> _fieldKeys = [
    'name',
    'description',
    'logo',
    'cover',
    'email',
    'phone',
    'website',
    'address',
    'hours',
    'subcategories',
    'socialLinks',
    'productsCount',
    'commercialReg',
    'taxNumber',
    'foundingYear',
  ];

  void initialize({String? businessId, Map<String, bool>? initialFields}) {
    final fields = initialFields ?? {for (var key in _fieldKeys) key: false};
    final percentage = _calculatePercentage(fields);
    state = BusinessProgressState(
      businessId: businessId,
      percentage: percentage,
      fields: fields,
    );
  }

  void updateField(String fieldKey, bool hasValue) {
    final newFields = Map<String, bool>.from(state.fields);
    newFields[fieldKey] = hasValue;
    final percentage = _calculatePercentage(newFields);
    state = state.copyWith(fields: newFields, percentage: percentage);
  }

  void updateMultipleFields(Map<String, bool> updates) {
    final newFields = Map<String, bool>.from(state.fields);
    newFields.addAll(updates);
    final percentage = _calculatePercentage(newFields);
    state = state.copyWith(fields: newFields, percentage: percentage);
  }

  int _calculatePercentage(Map<String, bool> fields) {
    if (fields.isEmpty) return 0;
    final filledCount = fields.values.where((v) => v).length;
    return ((filledCount / _fieldKeys.length) * 100).round();
  }

  void reset() {
    state = const BusinessProgressState();
  }
}

final businessProgressProvider =
    StateNotifierProvider<BusinessProgressNotifier, BusinessProgressState>((ref) {
  return BusinessProgressNotifier();
});
