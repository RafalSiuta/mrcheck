String maskText(String value, {String maskChar = '.'}) {
  if (value.isEmpty) return value;

  final buffer = StringBuffer();
  for (final rune in value.runes) {
    final char = String.fromCharCode(rune);
    if (char.trim().isEmpty) {
      buffer.write(char);
    } else {
      buffer.write(maskChar);
    }
  }

  return buffer.toString();
}
