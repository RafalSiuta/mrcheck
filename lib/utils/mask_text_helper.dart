String maskText(String value, {String maskChar = '.', bool preserveWhitespace = true}) {
  if (value.isEmpty) return value;

  final buffer = StringBuffer();
  for (final rune in value.runes) {
    final char = String.fromCharCode(rune);
    if (preserveWhitespace && char.trim().isEmpty) {
      buffer.write(char);
    } else {
      buffer.write(maskChar);
    }
  }

  return buffer.toString();
}
