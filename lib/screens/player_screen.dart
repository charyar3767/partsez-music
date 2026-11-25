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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 32),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Stack(
          clipBehavior: Clip.none,
          children: [
            for (int i = 6; i >= 1; i--)
              Transform.translate(
                offset: Offset(i * 0.7, i * 0.9),
                child: Text(
                  'Partsez Music',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: Color.lerp(
                      const Color(0xFFB02A5C),
                      const Color(0xFF2A0A1A),
                      i / 6,
                    ),
                  ),
                ),
              ),
            ShaderMask(
              shaderCallback: (r) => Renkler.gradient.createShader(r),
              child: const Text(
                'Partsez Music',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: AnimatedBuilder(
      animation: Listenable.merge([h.yndeks, h.sanaw]),
      builder: (context, _) {
            final a = h.hazirki;
            if (a == null) {
              return const Center(child: Text('Aydym saylanmady'));
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: Renkler.gradient,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: QueryArtworkWidget(
                      id: a.id,
                      type: ArtworkType.AUDIO,
                      artworkWidth: 280,
                      artworkHeight: 280,
                      artworkFit: BoxFit.cover,
                      artworkBorder: BorderRadius.circular(24),
                      size: 1000,
                      quality: 100,
                      keepOldArtwork: true,
                      nullArtworkWidget: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          color: Renkler.kart,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(Icons.music_note,
                            size: 110, color: Renkler.esasy),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    a.ady,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    a.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15, color: Renkler.tekstSoluk),
                  ),
                  const SizedBox(height: 20),
                  _progressKur(h),
                  const SizedBox(height: 8),
                  _dolandyrysKur(h),
                  const SizedBox(height: 12),
                  _gosmaKur(context, h, a),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _progressKur(OynadyjyHyzmat h) {
    return StreamBuilder<Duration?>(
      stream: h.player.durationStream,
      builder: (context, dSnap) {
        final dur = dSnap.data ?? Duration.zero;
        final maxV = max(dur.inMilliseconds, 1).toDouble();
        return StreamBuilder<Duration>(
          stream: h.player.positionStream,
          builder: (context, pSnap) {
            var pos = pSnap.data ?? Duration.zero;
            if (pos > dur) pos = dur;
            final val = pos.inMilliseconds.toDouble().clamp(0.0, maxV);
            return Column(
              children: [
                Slider(
                  min: 0,
                  max: maxV,
                  value: val.toDouble(),
                  onChanged: (v) =>
                      h.player.seek(Duration(milliseconds: v.round())),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(wagtFormat(pos),
                          style: const TextStyle(color: Renkler.tekstSoluk)),
                      Text(wagtFormat(dur),
                          style: const TextStyle(color: Renkler.tekstSoluk)),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _dolandyrysKur(OynadyjyHyzmat h) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: h.garyshyk,
          builder: (context, on, _) => IconButton(
            icon: Icon(Icons.shuffle,
                color: on ? Renkler.esasy : Renkler.tekstSoluk),
            onPressed: h.garyshykAyyr,
          ),
        ),
        IconButton(
          iconSize: 40,
          icon: const Icon(Icons.skip_previous),
          onPressed: h.ozal,
        ),
        StreamBuilder<bool>(
          stream: h.player.playingStream,
          initialData: h.player.playing,
          builder: (context, snap) {
            final oynayar = snap.data ?? false;
            return GestureDetector(
              onTap: h.bashlaDurdur,
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  gradient: Renkler.gradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  oynayar ? Icons.pause : Icons.play_arrow,
                  size: 42,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
        IconButton(
          iconSize: 40,
          icon: const Icon(Icons.skip_next),
          onPressed: () => h.indiki(),
        ),
        ValueListenableBuilder<int>(
          valueListenable: h.gaytalama,
          builder: (context, m, _) => IconButton(
            icon: Icon(
              m == 2 ? Icons.repeat_one : Icons.repeat,
              color: m == 0 ? Renkler.tekstSoluk : Renkler.esasy,
            ),
            onPressed: h.gaytalamaAyyr,
          ),
        ),
      ],
    );
  }

  /// Halaw (yurek) we uyky taymeri dugmeleri
  Widget _gosmaKur(BuildContext context, OynadyjyHyzmat h, Aydym a) {
    final fav = FavoritHyzmat.instance;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ValueListenableBuilder<Set<int>>(
          valueListenable: fav.halananlar,
          builder: (context, set, _) {
            final on = set.contains(a.id);
            return TextButton.icon(
              onPressed: () => fav.ayyr(a.id),
              icon: Icon(
                on ? Icons.favorite : Icons.favorite_border,
                color: Renkler.goshmaca,
              ),
              label: Text(
                on ? 'Halanan' : 'Halaw',
                style: const TextStyle(color: Renkler.tekstSoluk),
              ),
            );
          },
        ),
        ValueListenableBuilder<Duration?>(
          valueListenable: h.uykyGalan,
          builder: (context, galan, _) {
            final on = galan != null;
            return TextButton.icon(
              onPressed: () => _uykyAc(context, h),
              icon: Icon(
                Icons.bedtime_outlined,
                color: on ? Renkler.esasy : Renkler.tekstSoluk,
              ),
              label: Text(
                on ? wagtFormat(galan) : 'Uyky taymeri',
                style: TextStyle(
                  color: on ? Renkler.esasy : Renkler.tekstSoluk,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _uykyAc(BuildContext context, OynadyjyHyzmat h) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Renkler.kart,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Uyky taymeri',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              for (final m in [15, 30, 45, 60])
                ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: Text('$m minutdan son duruz'),
                  onTap: () {
                    h.uykyBashla(m);
                    Navigator.pop(ctx);
                  },
                ),
              if (h.uykyGalan.value != null)
                ListTile(
                  leading: const Icon(Icons.timer_off_outlined),
                  title: const Text('Taymeri ochur'),
                  onTap: () {
                    h.uykyOchur();
                    Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
