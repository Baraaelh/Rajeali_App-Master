String? requiredValidator(String value, {String fieldName = 'Field'}) {
  if (value.trim().isEmpty) {
    return '$fieldName is required';
  }
  return null;
}

String formatCounter(int value) {
  return value.toString();
}

String maskNationalId(String value) {
  if (value.length <= 4) {
    return '****';
  }
  final String visible = value.substring(value.length - 4);
  return '******$visible';
}

