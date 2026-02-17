import 'dart:convert';

import 'package:mrcash/models/currency_model/currency.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsHelper {
  const PrefsHelper();

  Future<bool> saveBool({
    required String key,
    required bool value,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(key, value);
  }

  Future<bool?> readBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  Future<bool> saveCurrencyOptions({
    required String key,
    required List<CurrencyOption> values,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = values.map((value) => value.toMap()).toList();
    return prefs.setString(key, jsonEncode(payload));
  }

  Future<List<CurrencyOption>> readCurrencyOptions({
    required String key,
    List<CurrencyOption> fallback = const <CurrencyOption>[],
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) {
      return List<CurrencyOption>.from(fallback);
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return List<CurrencyOption>.from(fallback);
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) => CurrencyOption.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (_) {
      return List<CurrencyOption>.from(fallback);
    }
  }

  Future<bool> updateCurrencyOptionAt({
    required String key,
    required int index,
    required CurrencyOption value,
    List<CurrencyOption> fallback = const <CurrencyOption>[],
  }) async {
    final current = await readCurrencyOptions(key: key, fallback: fallback);
    if (index < 0 || index >= current.length) {
      return false;
    }
    current[index] = value;
    return saveCurrencyOptions(key: key, values: current);
  }
}
