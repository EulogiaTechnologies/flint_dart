class Validator {
  static Future<void> validate(
      Map<String, dynamic> data, Map<String, String> rules) async {
    if (rules.isEmpty) return; // Skip if no rules

    final errors = <String, String>{};

    rules.forEach((field, rule) {
      final value = data[field];
      final ruleParts = rule.split('|');

      for (var part in ruleParts) {
        if (part == 'required' && (value == null || value.toString().isEmpty)) {
          errors[field] = 'The $field field is required.';
        } else if (part == 'string' && value is! String) {
          errors[field] = 'The $field must be a string.';
        } else if (part == 'int' && value is! int) {
          errors[field] = 'The $field must be an integer.';
        } else if (part == 'email' &&
            value is String &&
            !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
          errors[field] = 'The $field must be a valid email address.';
        }
      }
    });

    if (errors.isNotEmpty) {
      throw Exception('Validation failed: $errors');
    }
  }
}
