import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class GpaStore {
  static const key = 'gpa.workspace.v1';

  Future<Map<String, dynamic>?> read() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(key);
    return raw == null
        ? null
        : Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<void> write(Map<String, dynamic> data) async {
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.setString(key, jsonEncode(data))) {
      throw StateError('Your calculator could not be saved.');
    }
  }
}
