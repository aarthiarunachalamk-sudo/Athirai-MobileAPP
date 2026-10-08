/// Safe numeric parsing helpers to prevent runtime type cast exceptions
/// (e.g. "type 'String' is not a subtype of type 'num?' in type cast")
double parseDouble(dynamic value, [double defaultValue = 0.0]) {
  if (value == null) return defaultValue;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? defaultValue;
}

int parseInt(dynamic value, [int defaultValue = 0]) {
  if (value == null) return defaultValue;
  if (value is num) return value.toInt();
  final str = value.toString().trim();
  final d = double.tryParse(str);
  if (d != null) return d.toInt();
  return int.tryParse(str) ?? defaultValue;
}
