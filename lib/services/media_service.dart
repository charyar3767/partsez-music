import 'package:flutter/services.dart';

/// Android bilen baglanyshyk (aydymy hakyky pozmak)
class MediaHyzmat {
  static const MethodChannel _kanal = MethodChannel('partsez/media');

  /// true = poz boldy, false = ulanyjy ret etdi ya-da bolmady
  static Future<bool> aydymyPozmak(int id) async {
    try {
      final r = await _kanal.invokeMethod<bool>('deleteAudio', {'id': id});
      return r ?? false;
    } catch (e) {
      return false;
    }
  }
}
