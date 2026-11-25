import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';

/// Ulanyjynyn uytgeden at we artist maglumatlaryny saklayar
class DuzeltmeHyzmat {
  DuzeltmeHyzmat._();
  static final DuzeltmeHyzmat instance = DuzeltmeHyzmat._();

  static const String _acar = 'duzeltmeler';
  final Map<int, Map<String, String>> _data = {};

  Future<void> yukle() async {
    try {
      final p = await SharedPreferences.getInstance();
      final s = p.getString(_acar);
      if (s == null || s.isEmpty) return;
      final m = jsonDecode(s) as Map<String, dynamic>;
      _data.clear();
      m.forEach((k, v) {
        final id = int.tryParse(k);
        if (id == null || v is! Map) return;
        _data[id] = {
          'ady': (v['ady'] ?? '').toString(),
          'artist': (v['artist'] ?? '').toString(),
        };
      });
    } catch (e) {
      debugPrint('Duzeltmeleri okap bolmady: $e');
    }
  }

  bool bar(int id) => _data.containsKey(id);

  Aydym ulan(Aydym a) {
    final d = _data[a.id];
    if (d == null) return a;
    final ady = d['ady'];
    final art = d['artist'];
    return a.copyWith(
      ady: (ady == null || ady.isEmpty) ? null : ady,
      artist: (art == null || art.isEmpty) ? null : art,
    );
  }

  Future<void> sakla(int id, String ady, String artist) async {
    _data[id] = {'ady': ady, 'artist': artist};
    await _yaz();
  }

  Future<void> ochur(int id) async {
    if (_data.remove(id) != null) {
      await _yaz();
    }
  }

  Future<void> _yaz() async {
    try {
      final p = await SharedPreferences.getInstance();
      final m = _data.map((k, v) => MapEntry(k.toString(), v));
      await p.setString(_acar, jsonEncode(m));
    } catch (e) {
      debugPrint('Duzeltmeleri saklap bolmady: $e');
    }
  }
}
