import 'package:on_audio_query_forked/on_audio_query.dart';

class Aydym {
  final int id;
  final String ady;
  final String artist;
  final String yol;
  final int dowamlylyk; // millisekunt
  final String papka; // faylyn papkasynyn doly yoly

  const Aydym({
    required this.id,
    required this.ady,
    required this.artist,
    required this.yol,
    required this.dowamlylyk,
    required this.papka,
  });

  factory Aydym.fromSong(SongModel s) {
    final art = (s.artist == null || s.artist == '<unknown>')
        ? 'Nama-belli artist'
        : s.artist!;
    final i = s.data.lastIndexOf('/');
    return Aydym(
      id: s.id,
      ady: s.title,
      artist: art,
      yol: s.uri ?? s.data,
      dowamlylyk: s.duration ?? 0,
      papka: i <= 0 ? '' : s.data.substring(0, i),
    );
  }

  Aydym copyWith({String? ady, String? artist}) {
    return Aydym(
      id: id,
      ady: ady ?? this.ady,
      artist: artist ?? this.artist,
      yol: yol,
      dowamlylyk: dowamlylyk,
      papka: papka,
    );
  }
}
