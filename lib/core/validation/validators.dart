abstract final class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
  });

  factory ValidationResult.valid() => const _ValidResult();
  
  factory ValidationResult.invalid(String message) => _InvalidResult(message);
}

final class _ValidResult extends ValidationResult {
  const _ValidResult() : super(isValid: true);
}

final class _InvalidResult extends ValidationResult {
  const _InvalidResult(String message) 
      : super(isValid: false, errorMessage: message);
}

abstract final class Validators {
  static ValidationResult required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.invalid(
        '${fieldName ?? 'هذا الحقل'} مطلوب',
      );
    }
    return ValidationResult.valid();
  }

  static ValidationResult minLength(
    String? value,
    int minLength, {
    String? fieldName,
  }) {
    if (value == null || value.length < minLength) {
      return ValidationResult.invalid(
        '${fieldName ?? 'هذا الحقل'} يجب أن يكون $minLength حرف على الأقل',
      );
    }
    return ValidationResult.valid();
  }

  static ValidationResult maxLength(
    String? value,
    int maxLength, {
    String? fieldName,
  }) {
    if (value != null && value.length > maxLength) {
      return ValidationResult.invalid(
        '${fieldName ?? 'هذا الحقل'} يجب ألا يتجاوز $maxLength حرف',
      );
    }
    return ValidationResult.valid();
  }

  static ValidationResult email(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationResult.invalid('البريد الإلكتروني مطلوب');
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return ValidationResult.invalid('البريد الإلكتروني غير صحيح');
    }

    return ValidationResult.valid();
  }

  static ValidationResult password(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationResult.invalid('كلمة المرور مطلوبة');
    }

    if (value.length < 8) {
      return ValidationResult.invalid(
        'كلمة المرور يجب أن تكون 8 أحرف على الأقل',
      );
    }

    return ValidationResult.valid();
  }

  static ValidationResult url(String? value, {bool required = false, String? fieldName}) {
    if (value == null || value.isEmpty) {
      if (required) {
        return ValidationResult.invalid('${fieldName ?? 'الرابط'} مطلوب');
      }
      return ValidationResult.valid();
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return ValidationResult.invalid('${fieldName ?? 'الرابط'} غير صحيح');
    }

    return ValidationResult.valid();
  }

  static ValidationResult phone(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      if (required) {
        return ValidationResult.invalid('رقم الهاتف مطلوب');
      }
      return ValidationResult.valid();
    }

    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');

    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''))) {
      return ValidationResult.invalid('رقم الهاتف غير صحيح');
    }

    return ValidationResult.valid();
  }

  static ValidationResult combine(List<ValidationResult> results) {
    for (final result in results) {
      if (!result.isValid) {
        return result;
      }
    }
    return ValidationResult.valid();
  }

  static ValidationResult listNotEmpty<T>(
    List<T>? list, {
    String? fieldName,
  }) {
    if (list == null || list.isEmpty) {
      return ValidationResult.invalid(
        '${fieldName ?? 'القائمة'} يجب أن تحتوي على عنصر واحد على الأقل',
      );
    }
    return ValidationResult.valid();
  }

  static ValidationResult listMaxLength<T>(
    List<T>? list,
    int maxLength, {
    String? fieldName,
  }) {
    if (list != null && list.length > maxLength) {
      return ValidationResult.invalid(
        '${fieldName ?? 'القائمة'} يجب ألا تتجاوز $maxLength عنصر',
      );
    }
    return ValidationResult.valid();
  }

  static ValidationResult numeric(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return ValidationResult.invalid('${fieldName ?? 'هذا الحقل'} مطلوب');
    }

    if (int.tryParse(value) == null && double.tryParse(value) == null) {
      return ValidationResult.invalid(
        '${fieldName ?? 'هذا الحقل'} يجب أن يكون رقماً',
      );
    }

    return ValidationResult.valid();
  }

  static ValidationResult range(
    num? value,
    num min,
    num max, {
    String? fieldName,
  }) {
    if (value == null) {
      return ValidationResult.invalid('${fieldName ?? 'هذا الحقل'} مطلوب');
    }

    if (value < min || value > max) {
      return ValidationResult.invalid(
        '${fieldName ?? 'هذا الحقل'} يجب أن يكون بين $min و $max',
      );
    }

    return ValidationResult.valid();
  }
}
