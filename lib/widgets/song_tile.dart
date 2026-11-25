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
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.only(left: 16, right: 4),
      leading: QueryArtworkWidget(
        id: aydym.id,
        type: ArtworkType.AUDIO,
        artworkBorder: BorderRadius.circular(10),
        nullArtworkWidget: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: Renkler.gradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.music_note, color: Colors.white),
        ),
      ),
      title: Text(
        aydym.ady,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: oynayar ? Renkler.esasy : Colors.white,
        ),
      ),
      subtitle: Text(
        '${aydym.artist}  -  ${wagtFormat(Duration(milliseconds: aydym.dowamlylyk))}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Renkler.tekstSoluk),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<Set<int>>(
            valueListenable: fav.halananlar,
            builder: (context, set, _) {
              final on = set.contains(aydym.id);
              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => fav.ayyr(aydym.id),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    on ? Icons.favorite : Icons.favorite_border,
                    size: 22,
                    color: on ? Renkler.goshmaca : Renkler.tekstSoluk,
                  ),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            color: Renkler.kart,
            icon: const Icon(Icons.more_vert,
                size: 22, color: Renkler.tekstSoluk),
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'edit',
                child: Text('Ady we maglumaty uytget'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Pozmak'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
