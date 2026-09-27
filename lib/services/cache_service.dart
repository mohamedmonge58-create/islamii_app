// lib/services/cache_service.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// A small generic helper for caching JSON-serializable data locally
/// using SharedPreferences, with an optional time-to-live (TTL).
///
/// Usage pattern for a service:
///   1. Try [readIfFresh] with a TTL — if not null, use it immediately.
///   2. Otherwise call the network, and on success [save] the raw
///      decoded JSON (List or Map) under the same key.
///   3. If the network call fails, fall back to [read] (ignores
///      freshness) so the user still sees the last known data offline.
class CacheService {
  CacheService._();

  static const String _dataSuffix = '_data';
  static const String _timeSuffix = '_cached_at';

  /// Saves [value] (a JSON-encodable List/Map, i.e. already-decoded
  /// API JSON) under [key], stamped with the current time.
  static Future<void> save(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key + _dataSuffix, jsonEncode(value));
    await prefs.setInt(
      key + _timeSuffix,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Returns the raw decoded JSON stored under [key], or null if
  /// nothing has been cached yet. Ignores freshness/TTL — use this
  /// as an offline fallback after a failed network call.
  static Future<dynamic> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key + _dataSuffix);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  /// Returns the cached value only if it was saved less than [maxAge]
  /// ago, otherwise null (even if a stale copy exists — use [read]
  /// for that).
  static Future<dynamic> readIfFresh(String key, Duration maxAge) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedAtMs = prefs.getInt(key + _timeSuffix);
    if (cachedAtMs == null) return null;

    final cachedAt = DateTime.fromMillisecondsSinceEpoch(cachedAtMs);
    if (DateTime.now().difference(cachedAt) > maxAge) return null;

    return read(key);
  }

  /// Removes a single cached entry.
  static Future<void> clear(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key + _dataSuffix);
    await prefs.remove(key + _timeSuffix);
  }

  /// Removes every cached entry whose key starts with [prefix].
  /// Handy for pruning day-keyed caches (e.g. old prayer-time days).
  static Future<void> clearWithPrefix(String prefix) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(prefix)).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
  }
}