import 'dart:math';
import 'package:flutter/material.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import '../models/song.dart';
import '../services/audio_service.dart';
import '../services/favorit_service.dart';
import '../theme.dart';
import '../yardam.dart';

class OynadyjyEkrany extends StatelessWidget {
  const OynadyjyEkrany({super.key});

  @override
  Widget build(BuildContext context) {
    final h = OynadyjyHyzmat.instance;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            decoration: BoxDecoration(color: Renkler.kart.withOpacity(.85), shape: BoxShape.circle),
            child: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
        ),
        title: const Text('Häzirki aýdym', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -.55),
            radius: 1.1,
            colors: [Color(0x382E43A0), Renkler.fon],
          ),
        ),
        child: SafeArea(child: AnimatedBuilder(
          animation: Listenable.merge([h.yndeks, h.sanaw]),
          builder: (_, __) {
            final a = h.hazirki;
            if (a == null) return const Center(child: Text('Aydym saýlanmady'));
            return LayoutBuilder(builder: (_, constraints) {
              final size = min(constraints.maxWidth - 48, 330.0);
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 36),
                  child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    Container(
                      width: size,
                      height: size,
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        gradient: Renkler.gradient,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [BoxShadow(color: Color(0x804B5AC8), blurRadius: 28, offset: Offset(0, 16))],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: QueryArtworkWidget(
                          id: a.id,
                          type: ArtworkType.AUDIO,
                          artworkWidth: size,
                          artworkHeight: size,
                          artworkFit: BoxFit.cover,
                          size: 1000,
                          quality: 100,
                          keepOldArtwork: true,
                          nullArtworkWidget: Container(
                            decoration: const BoxDecoration(gradient: Renkler.kartGradient),
                            child: const Icon(Icons.music_note_rounded, size: 100, color: Renkler.esasy),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(a.ady, maxLines: 2, textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 7),
                    Text(a.artist, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, color: Renkler.tekstSoluk)),
                    const SizedBox(height: 18),
                    _progressKur(h),
                    const SizedBox(height: 8),
                    _dolandyrysKur(h),
                    const SizedBox(height: 8),
                    _gosmaKur(context, h, a),
                  ]),
                ),
              );
            });
          },
        ),),
      ),
    );
  }

  Widget _progressKur(OynadyjyHyzmat h) {
    return StreamBuilder<Duration>(
      stream: h.player.positionStream,
      builder: (_, positionSnapshot) {
        final duration = h.player.duration ?? Duration.zero;
        final position = positionSnapshot.data ?? Duration.zero;
        final maxValue = max(duration.inMilliseconds, 1).toDouble();
        final value = position.inMilliseconds.toDouble().clamp(0.0, maxValue);
        return Column(children: [
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              overlayShape: SliderComponentShape.noOverlay,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              activeTrackColor: Renkler.esasy,
              inactiveTrackColor: Renkler.tekstSoluk.withOpacity(.18),
              thumbColor: Renkler.tekst,
            ),
            child: Slider(
              min: 0,
              max: maxValue,
              value: value,
              onChanged: (v) => h.player.seek(Duration(milliseconds: v.round())),
            ),
          ),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(wagtFormat(position), style: const TextStyle(fontSize: 12, color: Renkler.tekstSoluk)),
              Text(wagtFormat(duration), style: const TextStyle(fontSize: 12, color: Renkler.tekstSoluk)),
            ],
          ))
        ]);
      },
    );
  }

  Widget _dolandyrysKur(OynadyjyHyzmat h) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      ValueListenableBuilder<bool>(
        valueListenable: h.garyshyk,
        builder: (_, on, __) => IconButton(onPressed: h.garyshykAyyr,
            icon: Icon(Icons.shuffle_rounded, color: on ? Renkler.esasy : Renkler.tekstSoluk)),
      ),
      IconButton(iconSize: 40, onPressed: h.ozal, icon: const Icon(Icons.skip_previous_rounded)),
      StreamBuilder<bool>(stream: h.player.playingStream, initialData: h.player.playing,
        builder: (_, snap) {
          final playing = snap.data ?? false;
          return InkWell(onTap: h.bashlaDurdur,
            borderRadius: BorderRadius.circular(40),
            child: Container(width: 76, height: 76,
              decoration: const BoxDecoration(gradient: Renkler.gradient, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Color(0x664E64B8), blurRadius: 18, offset: Offset(0, 8))]),
              child: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 44, color: Colors.white),
            ),
          );
        },
      ),
      IconButton(iconSize: 40, onPressed: h.indiki, icon: const Icon(Icons.skip_next_rounded)),
      ValueListenableBuilder<int>(
        valueListenable: h.gaytalama,
        builder: (_, mode, __) => IconButton(onPressed: h.gaytalamaAyyr,
            icon: Icon(mode == 2 ? Icons.repeat_one_rounded : Icons.repeat_rounded,
                color: mode == 0 ? Renkler.tekstSoluk : Renkler.esasy)),
      ),
    ]);
  }

  Widget _gosmaKur(BuildContext context, OynadyjyHyzmat h, Aydym a) {
    final fav = FavoritHyzmat.instance;
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      ValueListenableBuilder<Set<int>>(valueListenable: fav.halananlar,
        builder: (_, set, __) {
          final on = set.contains(a.id);
          return TextButton.icon(onPressed: () => fav.ayyr(a.id),
            icon: Icon(on ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: on ? Renkler.goshmaca : Renkler.tekstSoluk),
            label: Text(on ? 'Halanan' : 'Hala', style: const TextStyle(color: Renkler.tekstSoluk)),
          );
        },
      ),
      ValueListenableBuilder<Duration?>(valueListenable: h.uykyGalan,
        builder: (_, remaining, __) {
          final on = remaining != null;
          return TextButton.icon(onPressed: () => _uykyAc(context, h),
            icon: Icon(Icons.bedtime_rounded, color: on ? Renkler.esasy : Renkler.tekstSoluk),
            label: Text(on ? wagtFormat(remaining) : 'Uyky',
                style: TextStyle(color: on ? Renkler.esasy : Renkler.tekstSoluk)),
          );
        },
      ),
    ]);
  }

  void _uykyAc(BuildContext context, OynadyjyHyzmat h) {
    showModalBottomSheet(context: context, backgroundColor: Renkler.kart,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 8),
        Container(width: 36, height: 4, decoration: BoxDecoration(color: Renkler.tekstSoluk, borderRadius: BorderRadius.circular(2))),
        const Padding(padding: EdgeInsets.all(16), child: Text('Uyky taymeri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
        for (final m in [15, 30, 45, 60]) ListTile(leading: const Icon(Icons.timer_outlined), title: Text('$m minutdan soň duruz'),
          onTap: () { h.uykyBashla(m); Navigator.pop(context); }),
        if (h.uykyGalan.value != null) ListTile(leading: const Icon(Icons.timer_off_outlined), title: const Text('Taymeri öçür'),
          onTap: () { h.uykyOchur(); Navigator.pop(context); }),
      ])),
    );
  }
}
