import 'package:flutter/material.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import '../models/song.dart';
import '../services/favorit_service.dart';
import '../theme.dart';
import '../yardam.dart';

class AydymKart extends StatelessWidget {
  final Aydym aydym;
  final bool oynayar;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AydymKart({
    super.key,
    required this.aydym,
    required this.oynayar,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fav = FavoritHyzmat.instance;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 3, 12, 3),
      decoration: BoxDecoration(
        color: oynayar ? Renkler.esasy.withOpacity(.12) : Renkler.kart,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: oynayar ? Renkler.esasy.withOpacity(.55) : Colors.transparent,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: QueryArtworkWidget(
                    id: aydym.id,
                    type: ArtworkType.AUDIO,
                    artworkFit: BoxFit.cover,
                    nullArtworkWidget: Container(
                      decoration: const BoxDecoration(gradient: Renkler.gradient),
                      child: const Icon(Icons.music_note_rounded,
                          color: Colors.white, size: 26),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(aydym.ady,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: oynayar ? Renkler.esasy : Renkler.tekst,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${aydym.artist} · ${wagtFormat(Duration(milliseconds: aydym.dowamlylyk))}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Renkler.tekstSoluk),
                  ),
                ],
              )),
              ValueListenableBuilder<Set<int>>(
                valueListenable: fav.halananlar,
                builder: (_, set, __) {
                  final on = set.contains(aydym.id);
                  return IconButton(
                    tooltip: on ? 'Halananlardan ayyr' : 'Hala',
                    onPressed: () => fav.ayyr(aydym.id),
                    icon: Icon(on ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: on ? Renkler.goshmaca : Renkler.tekstSoluk,
                      size: 22,
                    ),
                  );
                },
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                color: Renkler.kart,
                icon: const Icon(Icons.more_vert_rounded,
                    size: 21, color: Renkler.tekstSoluk),
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Maglumaty üýtget')),
                  PopupMenuItem(value: 'delete', child: Text('Pozmak')),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
