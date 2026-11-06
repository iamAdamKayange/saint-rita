import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedPrayer {
  const SavedPrayer({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.journey,
  });

  final String id;
  final String title;
  final String subtitle;
  final String content;
  final String journey;

  factory SavedPrayer.fromJson(String value) {
    final data = jsonDecode(value) as Map<String, dynamic>;
    return SavedPrayer(
      id: data['id'] as String,
      title: data['title'] as String,
      subtitle: data['subtitle'] as String? ?? '',
      content: data['content'] as String? ?? '',
      journey: data['journey'] as String? ?? '',
    );
  }

  String toJson() => jsonEncode({
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'content': content,
    'journey': journey,
  });
}

class PrayerFavoritesProvider extends ChangeNotifier {
  static const _storageKey = 'saved_prayers_v1';
  List<SavedPrayer> _items = [];
  bool _loaded = false;

  List<SavedPrayer> get items => List.unmodifiable(_items);
  bool get isLoaded => _loaded;
  bool contains(String id) => _items.any((item) => item.id == id);

  PrayerFavoritesProvider() {
    load();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _items = (prefs.getStringList(_storageKey) ?? [])
        .map(SavedPrayer.fromJson)
        .toList();
    _loaded = true;
    notifyListeners();
  }

  Future<void> toggle(SavedPrayer prayer) async {
    if (!_loaded) await load();
    if (contains(prayer.id)) {
      _items.removeWhere((item) => item.id == prayer.id);
    } else {
      _items.insert(0, prayer);
    }
    await _persist();
  }

  Future<void> remove(String id) async {
    if (!_loaded) await load();
    _items.removeWhere((item) => item.id == id);
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _items.map((item) => item.toJson()).toList());
    notifyListeners();
  }
}
