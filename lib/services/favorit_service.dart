import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Halanan aydymlary telefonda saklayar
class FavoritHyzmat {
  FavoritHyzmat._();
  static final FavoritHyzmat instance = FavoritHyzmat._();

  static const String _acar = 'halananlar';

  final ValueNotifier<Set<int>> halananlar = ValueNotifier<Set<int>>({});

  Future<void> yukle() async {
    try {
      final p = await SharedPreferences.getInstance();
      final l = p.getStringList(_acar) ?? <String>[];
      halananlar.value = l.map(int.tryParse).whereType<int>().toSet();
    } catch (e) {
      debugPrint('Halananlary okap bolmady: $e');
    }
  }

  bool bar(int id) => halananlar.value.contains(id);

  Future<void> ochur(int id) async {
    if (!halananlar.value.contains(id)) return;
    final s = Set<int>.from(halananlar.value)..remove(id);
    halananlar.value = s;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(_acar, s.map((e) => e.toString()).toList());
    } catch (e) {
      debugPrint('Halananlary saklap bolmady: $e');
    }
  }

  Future<void> ayyr(int id) async {
    final s = Set<int>.from(halananlar.value);
    if (!s.add(id)) {
      s.remove(id);
    }
    halananlar.value = s;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(_acar, s.map((e) => e.toString()).toList());
    } catch (e) {
      debugPrint('Halananlary saklap bolmady: $e');
    }
  }
}
