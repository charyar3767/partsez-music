import 'package:flutter/material.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import '../screens/player_screen.dart';
import '../services/audio_service.dart';
import '../theme.dart';

class KiciOynadyjy extends StatelessWidget {
  const KiciOynadyjy({super.key});

  @override
  Widget build(BuildContext context) {
    final h = OynadyjyHyzmat.instance;
    return AnimatedBuilder(
      animation: Listenable.merge([h.yndeks, h.sanaw]),
      builder: (_, __) {
        final a = h.hazirki;
        if (a == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const OynadyjyEkrany()),
            ),
            child: Container(
              height: 68,
              padding: const EdgeInsets.fromLTRB(8, 8, 6, 8),
              decoration: BoxDecoration(
                gradient: Renkler.kartGradient,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Renkler.esasy.withOpacity(.28)),
                boxShadow: const [BoxShadow(
                  color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 6),
                )],
              ),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(width: 52, height: 52,
                    child: QueryArtworkWidget(
                      id: a.id,
                      type: ArtworkType.AUDIO,
                      artworkFit: BoxFit.cover,
                      nullArtworkWidget: Container(
                        decoration: const BoxDecoration(gradient: Renkler.gradient),
                        child: const Icon(Icons.music_note_rounded, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.ady, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    const SizedBox(height: 3),
                    Text(a.artist, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Renkler.tekstSoluk, fontSize: 11)),
                  ],
                )),
                StreamBuilder<bool>(
                  stream: h.player.playingStream,
                  initialData: h.player.playing,
                  builder: (_, snap) {
                    final playing = snap.data ?? false;
                    return IconButton(
                      onPressed: h.bashlaDurdur,
                      icon: Container(
                        width: 38, height: 38,
                        decoration: const BoxDecoration(gradient: Renkler.gradient, shape: BoxShape.circle),
                        child: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white, size: 23),
                      ),
                    );
                  },
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}
