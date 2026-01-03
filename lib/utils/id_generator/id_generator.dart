import 'package:uuid/uuid.dart';

const Uuid uuid = Uuid();

String makeId() {
  const String prefix = 'mr_cash_12345678-1234-5678-1234-56781234567';
  return '$prefix${uuid.v4()}';
}
