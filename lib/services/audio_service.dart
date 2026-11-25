import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/song.dart';

/// Bir sany umumy oynadyjy hyzmaty (singleton)
class OynadyjyHyzmat {
  OynadyjyHyzmat._() {
    // Haysy aydym calyp dur, shony yzarlayar (bildirisden geciselem)
    player.currentIndexStream.listen((i) {
      if (i != null) yndeks.value = i;
    });
    // Sanaw gutarsa, durup 0-dan gaytadan baslamaga taiyar
    player.processingStateStream.listen((s) {
      if (s == ProcessingState.completed) {
        player.pause();
        player.seek(Duration.zero);
      }
    });
  }

  static final OynadyjyHyzmat instance = OynadyjyHyzmat._();

  final AudioPlayer player = AudioPlayer();
  ConcatenatingAudioSource? _toplum;

  final ValueNotifier<List<Aydym>> sanaw = ValueNotifier<List<Aydym>>([]);
  final ValueNotifier<int> yndeks = ValueNotifier<int>(-1);
  final ValueNotifier<bool> garyshyk = ValueNotifier<bool>(false);
  // 0 = gaytalama yok, 1 = hemmesini gaytala, 2 = bir aydymy gaytala
  final ValueNotifier<int> gaytalama = ValueNotifier<int>(0);

  // Uyky taymeri: galan wagt (null bolsa, taymer yok)
  final ValueNotifier<Duration?> uykyGalan = ValueNotifier<Duration?>(null);
  Timer? _uykyTaymer;
  DateTime? _uykyBitis;

  Aydym? get hazirki {
    final i = yndeks.value;
    final l = sanaw.value;
    if (i < 0 || i >= l.length) return null;
    return l[i];
  }

  AudioSource _kaynakYasa(Aydym a) {
    return AudioSource.uri(
      Uri.parse(a.yol),
      tag: MediaItem(
        id: a.id.toString(),
        title: a.ady,
        artist: a.artist,
        duration: Duration(milliseconds: a.dowamlylyk),
      ),
    );
  }

  Future<void> oynat(List<Aydym> list, int index) async {
    sanaw.value = list;
    yndeks.value = index;
    try {
      final kaynak = ConcatenatingAudioSource(
        children: list.map(_kaynakYasa).toList(),
      );
      _toplum = kaynak;
      await player.setAudioSource(
        kaynak,
        initialIndex: index,
        initialPosition: Duration.zero,
      );
      player.play();
    } catch (e) {
      debugPrint('Aydymy acyp bolmady: $e');
    }
  }

  /// Pozulan aydymy oynatma sanawyndan ayyryar
  Future<void> aydymyAyyr(int id) async {
    final l = List<Aydym>.from(sanaw.value);
    final i = l.indexWhere((a) => a.id == id);
    if (i < 0) return;
    l.removeAt(i);
    if (l.isEmpty) {
      await player.stop();
      _toplum = null;
      sanaw.value = l;
      yndeks.value = -1;
      return;
    }
    try {
      await _toplum?.removeAt(i);
    } catch (e) {
      debugPrint('Sanawdan ayyryp bolmady: $e');
    }
    sanaw.value = l;
    if (yndeks.value >= l.length) {
      yndeks.value = l.length - 1;
    }
  }

  /// At / artist uytgese, oynayan sanawdaky maglumaty tazeleyar
  void maglumatAyyr(Aydym tazesi) {
    final l = List<Aydym>.from(sanaw.value);
    final i = l.indexWhere((a) => a.id == tazesi.id);
    if (i < 0) return;
    l[i] = tazesi;
    sanaw.value = l;
  }

  Future<void> bashlaDurdur() async {
    if (player.playing) {
      await player.pause();
    } else {
      player.play();
    }
  }

  Future<void> indiki() async {
    if (sanaw.value.isEmpty) return;
    if (player.hasNext) {
      await player.seekToNext();
    } else {
      await player.seek(Duration.zero, index: 0);
    }
    player.play();
  }

  Future<void> ozal() async {
    if (sanaw.value.isEmpty) return;
    if (player.position > const Duration(seconds: 3)) {
      await player.seek(Duration.zero);
      return;
    }
    if (player.hasPrevious) {
      await player.seekToPrevious();
    } else {
      await player.seek(Duration.zero, index: sanaw.value.length - 1);
    }
    player.play();
  }

  Future<void> garyshykAyyr() async {
    final v = !garyshyk.value;
    garyshyk.value = v;
    await player.setShuffleModeEnabled(v);
    if (v) {
      await player.shuffle();
    }
  }

  void gaytalamaAyyr() {
    final m = (gaytalama.value + 1) % 3;
    gaytalama.value = m;
    player.setLoopMode(
      m == 0 ? LoopMode.off : (m == 1 ? LoopMode.all : LoopMode.one),
    );
  }

  // ---------- Uyky taymeri ----------
  void uykyBashla(int minut) {
    uykyOchur();
    _uykyBitis = DateTime.now().add(Duration(minutes: minut));
    uykyGalan.value = Duration(minutes: minut);
    _uykyTaymer = Timer.periodic(const Duration(seconds: 1), (t) {
      final bitis = _uykyBitis;
      if (bitis == null) {
        t.cancel();
        return;
      }
      final galan = bitis.difference(DateTime.now());
      if (galan.inSeconds <= 0) {
        player.pause();
        uykyOchur();
      } else {
        uykyGalan.value = galan;
      }
    });
  }

  void uykyOchur() {
    _uykyTaymer?.cancel();
    _uykyTaymer = null;
    _uykyBitis = null;
    uykyGalan.value = null;
  }
}
