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
      builder: (context, _) {
        final a = h.hazirki;
        if (a == null) return const SizedBox.shrink();
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const OynadyjyEkrany()),
            );
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Renkler.kart,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Renkler.esasy.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                QueryArtworkWidget(
                  id: a.id,
                  type: ArtworkType.AUDIO,
                  artworkBorder: BorderRadius.circular(10),
                  nullArtworkWidget: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: Renkler.gradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.music_note, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.ady,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(a.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Renkler.tekstSoluk, fontSize: 12)),
                    ],
                  ),
                ),
                StreamBuilder<bool>(
                  stream: h.player.playingStream,
                  initialData: h.player.playing,
                  builder: (context, snap) {
                    final oynayar = snap.data ?? false;
                    return IconButton(
                      icon: Icon(oynayar ? Icons.pause : Icons.play_arrow),
                      onPressed: h.bashlaDurdur,
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: () => h.indiki(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
