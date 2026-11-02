import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/admin_entities.dart';
import '../models/admin_models.dart';

/// Saves the admin session in shared_preferences (localStorage on the web).
class SessionLocalDataSource {
  const SessionLocalDataSource(this._prefs);

  static const _key = 'admin_session';

  final SharedPreferences _prefs;

  /// Reads the saved session (or null if there is none or it's broken).
  AdminSession? read() {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    try {
      return AdminModels.sessionFromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Saves the session.
  Future<void> write(AdminSession session) =>
      _prefs.setString(_key, jsonEncode(AdminModels.sessionToJson(session)));

  /// Clears the session.
  Future<void> clear() => _prefs.remove(_key);
}
